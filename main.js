const { app, BrowserWindow, screen, ipcMain } = require('electron');
const path = require('path');

function createWindow() {
    const { width } = screen.getPrimaryDisplay().workAreaSize;
    const winWidth = 400;
    const winHeight = 150;

    const win = new BrowserWindow({
        width: winWidth,
        height: winHeight,
        x: Math.round((width - winWidth) / 2),
        y: 0,
        frame: false,
        transparent: true,
        alwaysOnTop: true,
        skipTaskbar: true,
        resizable: false,
        hasShadow: false,
        focusable: false,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js')
        }
    });

    win.setAlwaysOnTop(true, 'screen-saver');

    // Start click-through; "forward" still sends mouse-move events to the page
    win.setIgnoreMouseEvents(true, { forward: true });

    win.loadFile('index.html');
}

ipcMain.on('set-ignore-mouse', (event, ignore) => {
    const win = BrowserWindow.fromWebContents(event.sender);
    if (win) win.setIgnoreMouseEvents(ignore, { forward: true });
});


app.whenReady().then(createWindow);
app.on('window-all-closed', () => app.quit());