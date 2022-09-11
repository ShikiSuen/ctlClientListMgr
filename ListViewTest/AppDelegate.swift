//
//  AppDelegate.swift
//  ListViewTest
//
//  Created by ShikiSuen on 2022/9/11.
//

import Cocoa

enum IME {
  static let dlgOpenPath = NSOpenPanel()
}

enum mgrPrefs {
  static var clientsIMKTextInputIncapable: [String] = [
    "com.avast.browser", "com.brave.Browser", "com.brave.Browser.beta", "com.coccoc.Coccoc", "com.fenrir-inc.Sleipnir",
    "com.google.Chrome", "com.google.Chrome.beta", "com.google.Chrome.canary", "com.hiddenreflex.Epic",
    "com.maxthon.Maxthon", "com.microsoft.edgemac", "com.microsoft.edgemac.Canary", "com.microsoft.edgemac.Dev",
    "com.naver.Whale", "com.operasoftware.Opera", "com.valvesoftware.steam", "com.vivaldi.Vivaldi",
    "net.qihoo.360browser", "org.blisk.Blisk", "org.chromium.Chromium", "org.qt-project.Qt.QtWebEngineCore",
    "ru.yandex.desktop.yandex-browser"] {
      didSet {
        clientsIMKTextInputIncapable = Array(Set(clientsIMKTextInputIncapable))
        clientsIMKTextInputIncapable.sort()
      }
    }
}

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  private var instance = ctlClientListMgr.init(windowNibName: "frmClientListMgr")

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    instance.window?.center()
    instance.window?.orderFrontRegardless()  // 逼著關於視窗往最前方顯示
    instance.window?.level = .statusBar
    // NSApp.setActivationPolicy(.accessory)
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    // Insert code here to tear down your application
  }

  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}

