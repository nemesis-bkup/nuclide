
typedef enum
{
	GOPHER_ITEM_TEXT,
} gopherItem_t;

void GopherCallback_MessageReceived(gopherItem_t itemType, string titleString, string furtherData);
void Gopher_RequestIndex(string targetAddress);
void Gopher_QueryItem(string targetAddress, string targetPort, string selectorString, string searchQuery);
void Gopher_RequestText(string targetAddress, string targetPort, string selectorString, string searchQuery);
void Gopher_Frame(void);
