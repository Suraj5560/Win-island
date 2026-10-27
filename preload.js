const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('island', {
    setIgnoreMouse: (ignore) => ipcRenderer.send('set-ignore-mouse', ignore),
    mediaControl: (action) => ipcRenderer.send('media-control', action),
    onMedia: (callback) => ipcRenderer.on('media-update', (event, data) => callback(data))
});