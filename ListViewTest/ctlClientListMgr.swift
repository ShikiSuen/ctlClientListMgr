// (c) 2021 and onwards The vChewing Project (MIT-NTL License).
// ====================
// This code is released under the MIT license (SPDX-License-Identifier: MIT)
// ... with NTL restriction stating that:
// No trademark license is granted to use the trade names, trademarks, service
// marks, or product names of Contributor, except as required to fulfill notice
// requirements defined in MIT License.

import Cocoa

class ctlClientListMgr: NSWindowController, NSTableViewDelegate, NSTableViewDataSource {
  @IBOutlet var tblClients: NSTableView!
  @IBOutlet var btnRemoveClient: NSButton!
  @IBOutlet var btnAddClient: NSButton!
  @IBOutlet var lblClientMgrWindow: NSTextField!
  override func windowDidLoad() {
    super.windowDidLoad()
    localize()
    tblClients.delegate = self
    tblClients.allowsMultipleSelection = true
    tblClients.dataSource = self
    tblClients.reloadData()
  }
}

// MARK: - Implementations

extension ctlClientListMgr {
  func numberOfRows(in _: NSTableView) -> Int {
    mgrPrefs.clientsIMKTextInputIncapable.count
  }

  func callAlert(_ window: NSWindow, title: String, text: String? = nil) {
    let alert = NSAlert()
    alert.messageText = title
    if let text = text {
      alert.informativeText = text
    }
    alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
    alert.beginSheetModal(for: window)
  }

  @IBAction func btnAddClientClicked(_: Any) {
    guard let window = window else { return }
    let alert = NSAlert()
    alert.messageText = NSLocalizedString(
      "Please enter the client app bundle identifier(s) you want to register.", comment: ""
    )
    alert.informativeText = NSLocalizedString(
      "One record per line. Use Option+Enter to break lines.\nBlank lines will be dismissed.", comment: ""
    )
    alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
    alert.addButton(withTitle: NSLocalizedString("Just Select", comment: "") + "…")
    alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))

    let maxFloat = CGFloat(Float.greatestFiniteMagnitude)
    let scrollview = NSScrollView(frame: NSRect(x: 0, y: 0, width: 370, height: 380))
    let contentSize = scrollview.contentSize
    scrollview.borderType = .noBorder
    scrollview.hasVerticalScroller = true
    scrollview.hasHorizontalScroller = true
    scrollview.horizontalScroller?.scrollerStyle = .legacy
    scrollview.verticalScroller?.scrollerStyle = .legacy
    scrollview.autoresizingMask = [.width, .height]
    let theTextView = NSTextView(frame: NSRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
    theTextView.minSize = NSSize(width: 0.0, height: contentSize.height)
    theTextView.maxSize = NSSize(width: maxFloat, height: maxFloat)
    theTextView.isVerticallyResizable = true
    theTextView.isHorizontallyResizable = false
    theTextView.autoresizingMask = .width
    theTextView.textContainer?.containerSize = NSSize(width: contentSize.width, height: maxFloat)
    theTextView.textContainer?.widthTracksTextView = true
    scrollview.documentView = theTextView
    theTextView.enclosingScrollView?.hasHorizontalScroller = true
    theTextView.isHorizontallyResizable = true
    theTextView.autoresizingMask = [.width, .height]
    theTextView.textContainer?.containerSize = NSSize(width: maxFloat, height: maxFloat)
    theTextView.textContainer?.widthTracksTextView = false

    alert.accessoryView = scrollview
    alert.beginSheetModal(for: window) { result in
      switch result {
        case .alertFirstButtonReturn, .alertSecondButtonReturn:
          theTextView.textContainer?.textView?.string.components(separatedBy: "\n").filter { !$0.isEmpty }.forEach {
            self.applyNewValue($0)
          }
          if result == .alertFirstButtonReturn { break }
          IME.dlgOpenPath.title = NSLocalizedString(
            "Choose the target application bundle.", comment: ""
          )
          IME.dlgOpenPath.showsResizeIndicator = true
          IME.dlgOpenPath.showsHiddenFiles = true
          IME.dlgOpenPath.canChooseFiles = true
          IME.dlgOpenPath.canChooseDirectories = false
          IME.dlgOpenPath.beginSheetModal(for: window) { result in
            switch result {
              case .OK:
                guard let url = IME.dlgOpenPath.url else { return }
                var title = NSLocalizedString("The selected item is not a valid macOS application bundle.", comment: "")
                let text = NSLocalizedString("Please try again.", comment: "")
                guard let bundle = Bundle(url: url) else {
                  self.callAlert(window, title: title, text: text)
                  return
                }
                guard let identifier = bundle.bundleIdentifier else {
                  self.callAlert(window, title: title, text: text)
                  return
                }
                if mgrPrefs.clientsIMKTextInputIncapable.contains(identifier) {
                  title = NSLocalizedString(
                    "The selected item's identifier is already in the list.", comment: ""
                  )
                  self.callAlert(window, title: title)
                  return
                }
                self.applyNewValue(identifier)
              default: return
            }
          }
        default: return
      }
    }
  }

  private func applyNewValue(_ newValue: String) {
    guard !newValue.isEmpty else { return }
    var arrResult = mgrPrefs.clientsIMKTextInputIncapable
    arrResult.append(newValue)
    mgrPrefs.clientsIMKTextInputIncapable = arrResult.sorted()
    tblClients.reloadData()
    btnRemoveClient.isEnabled = (0..<mgrPrefs.clientsIMKTextInputIncapable.count).contains(
      tblClients.selectedRow)
  }

  @IBAction func btnRemoveClientClicked(_: Any) {
    guard let minIndexSelected = tblClients.selectedRowIndexes.min() else { return }
    if minIndexSelected >= mgrPrefs.clientsIMKTextInputIncapable.count { return }
    if minIndexSelected < 0 { return }
    var isLastRow = false
    tblClients.selectedRowIndexes.sorted().reversed().forEach { index in
      isLastRow = {
        if mgrPrefs.clientsIMKTextInputIncapable.count < 2 { return false }
        return minIndexSelected == mgrPrefs.clientsIMKTextInputIncapable.count - 1
      }()
      if index < mgrPrefs.clientsIMKTextInputIncapable.count {
        mgrPrefs.clientsIMKTextInputIncapable.remove(at: index)
      }
    }
    if isLastRow {
      tblClients.selectRowIndexes(.init(arrayLiteral: minIndexSelected - 1), byExtendingSelection: false)
    }
    tblClients.reloadData()
    btnRemoveClient.isEnabled = (0..<mgrPrefs.clientsIMKTextInputIncapable.count).contains(minIndexSelected)
  }

  func tableView(_: NSTableView, objectValueFor _: NSTableColumn?, row: Int) -> Any? {
    defer {
      self.btnRemoveClient.isEnabled = (0..<mgrPrefs.clientsIMKTextInputIncapable.count).contains(
        self.tblClients.selectedRow)
    }
    return mgrPrefs.clientsIMKTextInputIncapable[row]
  }

  private func localize() {
    guard let window = window else { return }
    window.title = NSLocalizedString("Client Manager", comment: "")
    lblClientMgrWindow.stringValue = NSLocalizedString(
      "Please manage the list of IMKTextInput-incompatible clients here. Clients listed here will trigger vChewing's built-in popup composition buffer window with maximum 20 reading counts holdable.",
      comment: ""
    )
    btnAddClient.title = NSLocalizedString("Add Client", comment: "")
    btnRemoveClient.title = NSLocalizedString("Remove Selected", comment: "")
  }
}
