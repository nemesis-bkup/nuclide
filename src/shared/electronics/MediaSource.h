class
ncMediaSource:ncActor
{
    void ncMediaSource(void);

#ifdef CLIENT
    virtual void OnRemoveEntity(void);
    virtual void Draw(void);
    virtual bool Input(float,float,float,float);
    virtual void ReceiveEntity(float,float);
    virtual void ReceiveEvent(float eventID);
    nonvirtual void RenderSource(string textureName);

#endif

#ifdef SERVER
    virtual void Respawn(void);
    virtual void EvaluateEntity(void);
    virtual float SendEntity(entity,float);
    virtual void SpawnKey(string, string);
    virtual void Input(entity entityActivator, string inputName, string dataField);

    nonvirtual bool AcceptsData(string dataFormat);
    nonvirtual void ParseDataFromBase64(string dataFormat, string dataString);
    nonvirtual bool ShareDataWithNamedSource(ncPlayer clientEntity, string sourceName, string dataFormat, string dataString);
#endif

private:

    NETWORKED_VECTOR(m_mediaSize)
    NETWORKED_STRING(m_acceptsData)
    NETWORKED_STRING(m_dataURL)
    NETWORKED_STRING(m_dataFormat)
    NETWORKED_STRING(m_gui64)

#ifdef CLIENT
    nonvirtual void _DrawInternal(void);
    nonvirtual bool _InputInternal(float,float,float,float);

    entity m_UIChain;
    entity m_uiInteractive;
    entity m_videoFeed;
#endif

};
