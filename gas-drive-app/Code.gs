/**
 * Google Apps Script backend for the consignment ledger web app.
 * Data is stored as JSON in Google Drive under a dedicated app folder.
 */
const APP_FOLDER_NAME = '委託販売管理アプリ';
const LEDGER_FILE_NAME = '委託販売管理_台帳.json';
const LEDGER_FILE_ID_KEY = 'LEDGER_FILE_ID';

function doGet() {
  return HtmlService.createTemplateFromFile('Index')
    .evaluate()
    .setTitle('委託販売管理')
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}

function loadLedger() {
  const file = getLedgerFile_();
  if (!file) {
    return {
      exists: false,
      fileName: LEDGER_FILE_NAME,
      updatedAt: null,
      data: null
    };
  }

  const text = file.getBlob().getDataAsString('UTF-8');
  const data = text ? JSON.parse(text) : null;
  return {
    exists: true,
    fileName: file.getName(),
    updatedAt: file.getLastUpdated().toISOString(),
    data
  };
}

function saveLedger(data) {
  if (!data || typeof data !== 'object' || Array.isArray(data)) {
    throw new Error('保存する台帳データが不正です。');
  }

  const lock = LockService.getScriptLock();
  lock.waitLock(30000);
  try {
    const file = getOrCreateLedgerFile_();
    file.setContent(JSON.stringify(data, null, 2));
    PropertiesService.getScriptProperties().setProperty(LEDGER_FILE_ID_KEY, file.getId());
    return {
      ok: true,
      fileName: file.getName(),
      updatedAt: file.getLastUpdated().toISOString()
    };
  } finally {
    lock.releaseLock();
  }
}

function getLedgerInfo() {
  const file = getLedgerFile_();
  return {
    exists: Boolean(file),
    folderName: APP_FOLDER_NAME,
    fileName: file ? file.getName() : LEDGER_FILE_NAME,
    updatedAt: file ? file.getLastUpdated().toISOString() : null
  };
}

function getOrCreateLedgerFile_() {
  const existing = getLedgerFile_();
  if (existing) return existing;

  const folder = getOrCreateAppFolder_();
  const file = folder.createFile(LEDGER_FILE_NAME, '{}', MimeType.PLAIN_TEXT);
  PropertiesService.getScriptProperties().setProperty(LEDGER_FILE_ID_KEY, file.getId());
  return file;
}

function getLedgerFile_() {
  const properties = PropertiesService.getScriptProperties();
  const storedId = properties.getProperty(LEDGER_FILE_ID_KEY);
  if (storedId) {
    try {
      return DriveApp.getFileById(storedId);
    } catch (error) {
      properties.deleteProperty(LEDGER_FILE_ID_KEY);
    }
  }

  const folder = getOrCreateAppFolder_();
  const files = folder.getFilesByName(LEDGER_FILE_NAME);
  if (!files.hasNext()) return null;
  const file = files.next();
  properties.setProperty(LEDGER_FILE_ID_KEY, file.getId());
  return file;
}

function getOrCreateAppFolder_() {
  const folders = DriveApp.getFoldersByName(APP_FOLDER_NAME);
  if (folders.hasNext()) return folders.next();
  return DriveApp.createFolder(APP_FOLDER_NAME);
}
