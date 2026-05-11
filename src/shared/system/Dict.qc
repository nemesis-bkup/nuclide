/*
 * Copyright (c) 2024 Vera Visions LLC.
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
*/

void
ncDict::ncDict(void)
{
    m_strBody = "";
}

string
ncDict::GetDeclBody(void)
{
    return (m_strBody);
}

string
ncDict::GetDeclBodyBase64(void)
{
    return base64encode(m_strBody, 256, 0);
}

void
ncDict::SetDeclBody(string textBody)
{
    m_strBody = textBody;
}

int
ncDict::GetInteger(string keyName)
{
    return (int)stoi(GetString(keyName));
}

float
ncDict::GetFloat(string keyName)
{
    return stof(GetString(keyName));
}

string
ncDict::GetString(string keyName)
{
    int spawnWords = (int)tokenize_console(m_strBody);

    /* iterate over our own spawnkeys first */
    for (int c = 0i; c < spawnWords; c+= 2i) {
        if (argv(c) == keyName) {
            return argv(c+1);
        }
    }

    return "";
}

vector
ncDict::GetVector(string keyName)
{
    return stov(GetString(keyName));
}

bool
ncDict::GetBool(string keyName)
{
    return stof(GetString(keyName)) ? true : false;
}

void
ncDict::_AddRemoveKey(string keyName, string setValue, bool delete)
{
    string newBody = "";
    int spawnWords = (int)tokenize_console(m_strBody);

    /* collect all existing key (except the one we wanna add, if it exists */
    for (int c = 0i; c < spawnWords; c+= 2i) {
        if (argv(c) != keyName) {
            newBody = sprintf("%s%S %S\n", newBody, argv(c), argv(c+1));
        }
    }

    if (delete == false) {
        newBody = sprintf("%s%S %S\n", newBody, keyName, setValue);
    }

    m_strBody = newBody;
}

void
ncDict::AddKey(string keyName, string setValue)
{
    _AddRemoveKey(keyName, setValue, false);
}

void
ncDict::RemoveKey(string keyName)
{
    _AddRemoveKey(keyName, "", true);
}

int
ncDict::TokenCount(void)
{
    return (int)tokenize_console(m_strBody);
}

ncDict
ncDict::InitWithSpawnDataFromBase64(string base64Data)
{
    ncDict newDict = spawn(ncDict);
    int byteCount = 0i;
    newDict.SetDeclBody(base64decode(base64Data, byteCount));
    return (newDict);
}

ncDict
ncDict::InitWithSpawnData(string spawnData)
{
    ncDict newDict = spawn(ncDict);
    newDict.SetDeclBody(spawnData);
    return (newDict);
}

string
ncDict::Name(void)
{
    return (m_declPath);
}

string
ncDict::Type(void)
{
    return (m_dictType);
}

bool
ncDict::ValidType(string type)
{
    switch (type) {
    case "typeinfo":
    case "video":
    case "audio":
    case "email":
    case "picture":
    case "app":
    case "object":
    case "text":
        return (true);
    default:
        return (false);
    }
}

void
ncDict::TransmitToEntity(float serversideEntityNum)
{
    int spawnWords = (int)tokenize_console(m_strBody);

    /* there should be a handshake first ideally, but who cares. */
    localcmd(sprintf("cmd dictStart %d %s\n", serversideEntityNum, m_dictType));

    /* iterate over our own spawnkeys first */
    for (int c = 0i; c < spawnWords; c+= 2i) {
        localcmd(sprintf("cmd dictLine %d %s %s %S\n", serversideEntityNum, m_dictType, argv(c), argv(c+1)));
    }

    localcmd(sprintf("cmd dictEnd %s %d\n", m_dictType, serversideEntityNum));
}

ncDict
ncDict::LoadDeclFromFile(string declName, string fileName)
{
    filestream fh;
    ncDict newDict;
    string tempString;
    int braceDepth = 0i;
    string lastWord = __NULL__;
    string lastDecl = "";

    string cachedPath = g_string_null;
    string cachedFile = g_string_null;
    string cachedContents = g_string_null;
    string dictType = g_string_null;

    /* find an existing dict in memory */
    for (ncDict dictSearch = 0; (dictSearch = (ncDict)find(dictSearch, ::classname, "ncDict"));) {
        if (dictSearch.m_filePath == fileName && dictSearch.m_declPath == declName) {
            ncLog("found cached decl %S", declName);
            return (dictSearch);
        }
    }

    fh = fopen(strcat("decls/", fileName), FILE_READ);

#ifdef CLIENT
    /* then check the player dir */
    if (fh < 0) {
        fh = fopen(strcat("data/players/", cvars.GetString("cl_cred"), "/decls/", fileName), FILE_READ);

        if (fh < 0) {
            ncError("Can't read %S", fileName);
            return __NULL__;
        }
    }
#else
    if (fh < 0) {
        ncError("Can't read %S", fileName);
        return __NULL__;
    }
#endif

    newDict = spawn(ncDict);
    newDict.m_declPath = declName;
    newDict.m_filePath = fileName;

    while ((tempString = fgets(fh))) {
        for (int i = 0i; i < tokenize_console(tempString); i++) {
            string word = argv(i);

            switch (word) {
            case "{":
                braceDepth++;
                break;
            case "}":
                braceDepth--;

                /* we've reached the end of a definition */
                if (braceDepth == 0) {
                    newDict.m_dictType = dictType;

                    /* we found it, we're done */
                    if (STRING_SET(lastDecl) && lastDecl == declName) {
                        break;
                    }
                    lastDecl = "";
                    dictType = "";
                }
                break;
            default:
                /* anything outside braces defines the classname for the next def */
                if (braceDepth == 0 && ValidType(lastWord) == true ) {
                    dictType = lastWord;
                    lastDecl = word;
                } else if (braceDepth == 1) {
                    if (lastDecl == declName) { /* rest gets dumped into spawndata */
                        newDict.m_strBody = strcat(newDict.m_strBody, "\"", word, "\"", " ");
                    }
                }
            }
            lastWord = strtolower(word);
        }

#if 0
        if (c == 1) {

        } else if (c == 2) {
            newDict.AddKey(argv(0), argv(1));
        }
#endif
    }

    fclose(fh);

    /* failed to find any key-value pairs. empty */
    if (!STRING_SET(newDict.m_strBody)) {
        ncLog("discarding empty dict %S", declName);
        remove(newDict);
        return (__NULL__);
    }

    ncLog("allocated dict %S", declName);
    return (newDict);
}

