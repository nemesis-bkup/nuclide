ncProfile g_activeProfile;

/* Profile Containers */
void
ncProfile::ncProfile(void)
{

}

void
ncProfile::LoadConfig(void)
{
	/* load the profile data */
	localcmd(sprintf("cfg_load \"%s.cfg\"\n", m_profileName));
	localcmd(sprintf("set cl_cred %S\n", m_profileName));
}

void
ncProfile::SaveConfig(void)
{
	/* save the profile data */
	localcmd(sprintf("cfg_save \"%s.cfg\"\n", m_profileName));
}

ncProfile
ncProfile::NewNamed(string profileName)
{
	ncProfile outputProfile = __NULL__;
	filestream keyFile = fopen(sprintf("players/%s/key", profileName) , FILE_WRITE);

	/* write the key file */
	if (keyFile >= 0) {
		fputs(keyFile, "// Vera Key File - do not share the contents of this file");
		fputs(keyFile, " ");
		fclose(keyFile);

		/* register the creds */
		localcmd(sprintf("cl_cred_register %S\n", profileName));

		/* now we load it like any other profile. */
		outputProfile = LoadFromDiskByName(profileName);
		
		/* force a config file to be created */
		outputProfile.SaveConfig();
		return (outputProfile);
	}

	return (__NULL__);	
}

ncProfile
ncProfile::LoadFromDiskByName(string profileName)
{
	ncProfile newProfile = spawn(ncProfile);
	newProfile.m_profileName = profileName;
	newProfile.m_profileCert = profileName;
	/* we could load the key file here, if we had any use for it */
	ncLog("Loaded profile %S.", profileName);
	return (newProfile);	
}

void
ncProfile::Delete(void)
{
	fremove(sprintf("players/%s/key", m_profileName));
	fremove(sprintf("players/%s", m_profileName));
	localcmd(sprintf("cl_cred_delete %S\n", m_profileName));
	ncLog("Deleted profile %S.", m_profileName);
	remove(this);
}

/* The manager of profiles... */
void
ncProfileManager::ncProfileManager(void)
{
}

void
ncProfileManager::Init(void)
{
	searchhandle searchProfiles;
	string activeProfileName = "Default";
	filestream activeProfileFile;

	/* search for available profiles, init them into ncProfile objects. */
	searchProfiles = search_begin("data/players/*/key", SEARCH_NAMESORT, true);

	for (int i = 0i; i < search_getsize(searchProfiles); i++) {
		int c = tokenizebyseparator(search_getfilename(searchProfiles, i), "/");
		string profileName = argv(2);

		/* make a record of the profile */
		ncProfile::LoadFromDiskByName(profileName);
	}

	/* read players/active.txt to find out what our last selected profile was. */
	activeProfileFile = fopen("players/active.txt", FILE_READ);

	/* it's not the end of the world if it doesn't exist. we'll assume we have to create a new profile later */
	if (activeProfileFile >= 0) {
		activeProfileName = fgets(activeProfileFile);
		fclose(activeProfileFile);
	}

	/* switch to named profile. */
	if (NamedProfileExistsOnDisk(activeProfileName) == false) {
		/* doesn't exist? create it - most likely "Default" here */
		if (CreateNamedProfile(activeProfileName) == false) {
			error("Will not proceed without profile container. Abort.");
			return;
		}
	}

	SetProfileByName(activeProfileName);
}

void
ncProfileManager::Shutdown(void)
{
	SaveActiveProfile();
}

ncProfile
ncProfileManager::GetActiveProfile(void)
{
	return (g_activeProfile);
}

void
ncProfileManager::SaveActiveProfile(void)
{
	ncProfile activeProfile = GetActiveProfile();

	if (!activeProfile) {
		ncError("Can't save. No active profile set.");
		return;
	}

	activeProfile.SaveConfig();
}

ncProfile
ncProfileManager::FindProfileByName(string profileName)
{
	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(profileName)) {
		return (__NULL__);
	}

	for (ncProfile f = __NULL__; (f = (ncProfile)find(f, ::classname, "ncProfile"));) {
		if (f.m_profileName == profileName) {
			return (f);
		}
	}

	return (__NULL__);
}

bool
ncProfileManager::SetProfileByName(string profileName)
{
	ncProfile foundProfile = __NULL__;
	filestream activeProfileFile;
	
	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(profileName)) {
		return (false);
	}

	foundProfile = FindProfileByName(profileName);

	if (!foundProfile) {
		return (false);
	}

	foundProfile.LoadConfig();
	g_activeProfile = foundProfile;
	ncLog("Set active profile to %S.", profileName);

	/* save our current preference to disk (imitating iw) */
	activeProfileFile = fopen("players/active.txt", FILE_WRITE);

	/* we won't fail here, as we may be reading from a read-only copy of a game */
	if (activeProfileFile >= 0) {
		fputs(activeProfileFile, profileName);
		fclose(activeProfileFile);
	}

	return (true);
}

bool
ncProfileManager::CreateNamedProfile(string profileName)
{
	ncProfile result = __NULL__;
	string targetName = strtrim(profileName);

	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(targetName)) {
		ncError("Empty name won't work");
		return (false);
	}

	if (FindProfileByName(targetName) != __NULL__) {
		ncError("Profile %S already exists.", targetName);
		return (false);
	}

	result = ncProfile::NewNamed(targetName);

	if (!result) {
		ncError("Unable to create profile %S.", targetName);
		return (false);
	}

	return (true);
}

void
ncProfileManager::SaveWeb(string videoName, string videoTitle, string videoPreview, string videoURL, string audioURL)
{
}

void
ncProfileManager::SaveText(string videoName, string videoTitle, string videoPreview, string videoURL, string audioURL)
{


	localcmd("reloadTextDecl");
}

void
ncProfileManager::SaveVideo(string videoName, string videoTitle, string videoPreview, string videoURL, string audioURL)
{
	ncProfile activeProfile = GetActiveProfile();
	string profileName = activeProfile.m_profileName;

	if (!STRING_SET(videoName)) {
		ncError("Name not defined");
		return;
	}

	if (!STRING_SET(videoURL)) {
		ncError("Name not defined");
		return;
	}

	string videoDictPath = sprintf("data/players/%s/decls/videos/%s.video", profileName, videoName);
	filestream videoDictStream;

	if (whichpack(videoDictPath)) {
		ncWarning("Video named %S already exists in profile", videoName);
		return;
	}

	videoDictStream = fopen(videoDictPath, FILE_WRITE);

	if (videoDictStream >= 0) {
		fputs(videoDictStream, sprintf("%s %s\n", "video", videoName));
		fputs(videoDictStream, "{\n");

		if (STRING_SET(videoTitle)) {
			fputs(videoDictStream, sprintf("\t%S %S\n", "name", videoTitle));
		}

		if (STRING_SET(videoPreview)) {
			fputs(videoDictStream, sprintf("\t%S %S\n", "preview", videoPreview));
		}

		if (substring(videoURL, 0, 4) == "avs:") {
			fputs(videoDictStream, sprintf("\t%S %S\n", "video", substring(videoURL, 4, -1)));
		} else if (substring(videoURL, 0, 3) == "av:") {
			fputs(videoDictStream, sprintf("\t%S %S\n", "video", substring(videoURL, 3, -1)));
		} else {
			fputs(videoDictStream, sprintf("\t%S %S\n", "video", videoURL));
		}

		if (STRING_SET(audioURL)) {
			fputs(videoDictStream, sprintf("\t%S %S\n", "audio", audioURL));
		}

		fputs(videoDictStream, "}\n");
		fclose(videoDictStream);
	}

	localcmd("reloadVideoDecl");
}

void
ncProfileManager::SaveAudio(string videoName, string videoTitle, string videoPreview, string videoURL, string audioURL)
{


	localcmd("reloadAudioDecl");
}

void
ncProfileManager::SaveSoftware(string videoName, string videoTitle, string picturePreview, string embedURL, string softwareDescription)
{
	ncProfile activeProfile = GetActiveProfile();
	string profileName = activeProfile.m_profileName;

	if (!STRING_SET(videoName)) {
		ncError("Name not defined");
		return;
	}

	if (!STRING_SET(picturePreview)) {
		ncError("Picture not defined");
		return;
	}

	string videoDictPath = sprintf("data/players/%s/decls/apps/%s.app", profileName, videoName);
	filestream videoDictStream;

	if (whichpack(videoDictPath)) {
		ncWarning("Software named %S already exists in profile", videoName);
		return;
	}

	videoDictStream = fopen(videoDictPath, FILE_WRITE);

	if (videoDictStream >= 0) {
		fputs(videoDictStream, sprintf("%s %s\n", "app", videoName));
		fputs(videoDictStream, "{\n");

		if (STRING_SET(videoTitle)) {
			fputs(videoDictStream, sprintf("\t%S %S\n", "name", videoTitle));
		}

		fputs(videoDictStream, sprintf("\t%S %S\n", "preview", picturePreview));
		fputs(videoDictStream, sprintf("\t%S %S\n", "info", softwareDescription));
		fputs(videoDictStream, sprintf("\t%S %S\n", "url", embedURL));
		fputs(videoDictStream, "\t\"captureMouse\" \"1\"\n");
		fputs(videoDictStream, "\t\"webShim\" \"1\"\n");

		fputs(videoDictStream, "}\n");
		fclose(videoDictStream);
	}

	localcmd("reloadAppDecl");
}

void
ncProfileManager::SaveImage(string videoName, string videoTitle, string picturePreview, string pictureURL, string unused1)
{
	ncProfile activeProfile = GetActiveProfile();
	string profileName = activeProfile.m_profileName;

	if (!STRING_SET(videoName)) {
		ncError("Name not defined");
		return;
	}

	if (!STRING_SET(picturePreview)) {
		ncError("Preview not defined");
		return;
	}

	if (!STRING_SET(pictureURL)) {
		ncError("Picture not defined");
		return;
	}

	string videoDictPath = sprintf("data/players/%s/decls/pictures/%s.picture", profileName, videoName);
	filestream videoDictStream;

	if (whichpack(videoDictPath)) {
		ncWarning("Picture named %S already exists in profile", videoName);
		return;
	}

	videoDictStream = fopen(videoDictPath, FILE_WRITE);

	if (videoDictStream >= 0) {
		vector previewRes = drawgetimagesize(picturePreview);
		fputs(videoDictStream, sprintf("%s %s\n", "picture", videoName));
		fputs(videoDictStream, "{\n");

		if (STRING_SET(videoTitle)) {
			fputs(videoDictStream, sprintf("\t%S %S\n", "name", videoTitle));
		}

		fputs(videoDictStream, sprintf("\t%S %S\n", "preview", picturePreview));
		fputs(videoDictStream, sprintf("\t%S %S\n", "picture", pictureURL));
		fputs(videoDictStream, sprintf("\t%S \"%d %d\"\n", "resolution", previewRes[0], previewRes[1]));


		fputs(videoDictStream, "}\n");
		fclose(videoDictStream);
	}

	localcmd("reloadPictureDecl");
}

void
ncProfileManager::ShareWeb(string resourceURL)
{
	tokenizebyseparator(resourceURL, "/");
	string siteName = argv(2);
	string fullURL = argv(3);
	localcmd(sprintf("cmd shareWWW %S %S\n", siteName, resourceURL));
}

void
ncProfileManager::ShareText(string resourceURL)
{
	tokenizebyseparator(resourceURL, "/");
	string siteName = argv(2);
	string fullURL = argv(3);
	localcmd(sprintf("cmd shareText %S %S\n", siteName, resourceURL));
}

void
ncProfileManager::ShareVideo(string resourceURL)
{
	tokenizebyseparator(resourceURL, "/");
	string siteName = argv(2);
	string fullURL = argv(3);
	localcmd(sprintf("cmd shareVideo %S %S %S %S\n", "remote_video", "Remote URL", "", resourceURL));
}

void
ncProfileManager::ShareAudio(string resourceURL)
{
	tokenizebyseparator(resourceURL, "/");
	string siteName = argv(2);
	string fullURL = argv(3);
	localcmd(sprintf("cmd shareAudio %S %S %S %S\n", "remote_audio", "Remote URL", "", resourceURL));
}

void
ncProfileManager::ShareSoftware(string resourceURL)
{

}

void
ncProfileManager::ShareImage(string resourceURL)
{
	int c = tokenizebyseparator(resourceURL, "/");

	string siteName = argv(2);
	string fileName = argv(c - 1);

	precache_pic(resourceURL);
	vector imageAspect = drawgetimagesize(resourceURL);
	float standardLength = 118.9;

	if ((imageAspect[0] <= 0.0) || (imageAspect[1] <= 0.0)) {
		return;
	}

	/* 2d normalize */
	if (imageAspect[0] > imageAspect[1]) {
		imageAspect[1] = imageAspect[1] / imageAspect[0];
		imageAspect[0] = 1.0f;
	} else {
		imageAspect[0] = imageAspect[0] / imageAspect[1];
		imageAspect[1] = 1.0f;
	}

	/* length * aspect = decent approximation for our image turned poster */
	vector realSize = [standardLength * imageAspect[0], standardLength * imageAspect[1]];

	/* to game units */
	realSize[0] *= (1/2.54);
	realSize[1] *= (1/2.54);
	localcmd(sprintf("cmd sharePicture %S %S %d %d\n", fileName, resourceURL, realSize[0], realSize[1]));
}

bool
ncProfileManager::DeleteNamedProfile(string profileName)
{
	ncProfile foundProfile = __NULL__;
	ncProfile activeProfile = GetActiveProfile();

	/* cancel out early. can't have empty name profiles */
	if (!STRING_SET(profileName)) {
		return (false);
	}

	foundProfile = FindProfileByName(profileName);

	if (!foundProfile) {
		ncError("Won't delete %S, no such profile.", profileName);
		return (false);
	}

	if (activeProfile == foundProfile) {
		ncError("Won't delete %S, profile is currently active.", profileName);
		return (false);
	}

	foundProfile.Delete();
	return (true);
}

bool
ncProfileManager::NamedProfileExistsOnDisk(string targetName)
{
	/* if the key file doesn't exist, it's a safe bet. */
	if not (whichpack(sprintf("data/players/%s/key", targetName))) {
		return (false);
	}

	return (true);
}

void
ncProfileManager::ListProfiles(void)
{
	ncProfile activeProfile = GetActiveProfile();
	printf("List of profiles:\n");

	for (ncProfile f = __NULL__; (f = (ncProfile)find(f, ::classname, "ncProfile"));) {
		if (f == activeProfile) {
			printf("\t[%s]\n", f.m_profileName);
		} else {
			printf("\t^8%s\n", f.m_profileName);
		}
	}
}
