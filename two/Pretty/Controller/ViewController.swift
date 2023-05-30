//
//  ViewController.swift
//  Pretty
//
//  Created by Octree on 2018/4/5.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Cocoa

extension NSView {
    func screenshot() -> NSImage {
        let viewToCapture = self
        let rep = viewToCapture.bitmapImageRepForCachingDisplay(in: viewToCapture.bounds)!
        viewToCapture.cacheDisplay(in: viewToCapture.bounds, to: rep)

        let img = NSImage(size: viewToCapture.bounds.size)
        img.addRepresentation(rep)
        return img
    }
    
}

extension NSImage {
    @discardableResult
    func saveAsPNG(url: URL) -> Bool {
        guard let tiffData = self.tiffRepresentation else {
            print("failed to get tiffRepresentation. url: \(url)")
            return false
        }
        let imageRep = NSBitmapImageRep(data: tiffData)
        guard let imageData = imageRep?.representation(using: .png, properties: [:]) else {
            print("failed to get PNG representation. url: \(url)")
            return false
        }
        do {
            try imageData.write(to: url)
            return true
        } catch {
            print("failed to write to disk. url: \(url)")
            return false
        }
    }
}

extension ViewController: NSSearchFieldDelegate {
    
    func saveImage() {
        let openPanel = NSOpenPanel()       // Authorize access in sandboxed mode
        openPanel.message = "选则图片保存目录"
        openPanel.prompt = "选则"
        openPanel.canChooseFiles = false    // Only select or create Directory here ; you can select the real Desktop
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = true
        openPanel.begin() {                              // In the completion, Save the file
            (result2) -> Void in
            if result2 == NSApplication.ModalResponse.OK {
//                storeBookm ark(url: openPanel.url!)          // Save the bookmark for future use if needed
                
                let savePanel = NSSavePanel()
                savePanel.title = "请输入图片名称"
                savePanel.prompt = NSLocalizedString("Create", comment: "enableFileMenuItems")
                savePanel.allowedFileTypes = ["png"]   // if you want to specify file signature
                let fileManager = FileManager.default
                
                savePanel.begin() { [weak self] (result) -> Void in
                    if result == NSApplication.ModalResponse.OK {
                        let fileWithExtensionURL = savePanel.url!  //  May test that file does not exist already
                        if fileManager.fileExists(atPath: fileWithExtensionURL.path) {
                            self?.relationView.screenshot().saveAsPNG(url: fileWithExtensionURL)
                        } else {
                            self?.relationView.screenshot().saveAsPNG(url: fileWithExtensionURL)
                        }
                    }
                }
            }
        }
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
//        searchAction()
    }
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            searchAction()
            return true
        }
        
        return false
    }
    
    @objc func searchAction() {
        
//        if searchView.stringValue == "" {
            relationView.prettyRelation = fullprettyRelation
//            return
//        }
        
        let size = relationView.prettyRelation.preferredSize
        relationView.frame = CGRect(x: (scrollView.frame.size.width - size.width) / 2.0,
                                    y: (scrollView.frame.size.height - size.height) / 2.0,
                                    width: size.width,
                                    height: size.height)
        
        for view in relationView.itemMap.values {
            
            if view.text.lowercased() == searchView.stringValue.lowercased() {
                
                
                switch segmentControl.selectedSegment {
                case 0:
                    var frame = view.frame
                    
                    if frame.origin.y < scrollView.documentVisibleRect.origin.y {
                        frame.origin.y -= 100
                    } else {
                        frame.origin.y += 100
                    }
                    
                    scrollView.documentView?.scrollToVisible(frame)
                    
                    
//                    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"transform"];
//                    CATransform3D tr = CATransform3DIdentity;
//                    tr = CATransform3DTranslate(tr, self.bounds.size.width/2, self.bounds.size.height/2, 0);
//                    tr = CATransform3DScale(tr, 3, 3, 1);
//                    tr = CATransform3DTranslate(tr, -self.bounds.size.width/2, -self.bounds.size.height/2, 0);
//                    scale.toValue = [NSValue valueWithCATransform3D:tr];
                    
                    let animation = CABasicAnimation(keyPath: "transform")
                    animation.repeatCount = 2
                    animation.duration = 0.6
                    animation.autoreverses = true
                    var tr = CATransform3DIdentity
                    tr = CATransform3DTranslate(tr, view.bounds.size.width / 2, view.bounds.size.height / 2, 0);
                    tr = CATransform3DScale(tr, 2.0, 2.0, 1);
                    tr = CATransform3DTranslate(tr, -view.bounds.size.width / 2, -view.bounds.size.height / 2, 0);
                    animation.toValue = CATransform3DIdentity
                    animation.toValue = tr
                    view.layer?.add(animation, forKey: "scale")
                    
                    // Create the scale animation
//                    let animation = CABasicAnimation(keyPath: "transform.scale")
//                    animation.repeatCount = 2
//                    animation.duration = 0.6
//                    animation.fromValue = CATransform3DMakeScale(1.0, 1.0, 1.0)
//                    animation.toValue = CATransform3DMakeScale(2.0, 2.0, 1.0)
//                    animation.autoreverses = true
//                    view.layer?.mask?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
//                    view.layer?.mask?.contentsGravity = "center"
//                    view.layer?.add(animation, forKey: "scale")
                    
                    
//                    let animation2 = CABasicAnimation(keyPath: "transform.position")
//                    animation2.repeatCount = 2
//                    animation2.duration = 0.6
//                    animation2.fromValue = CGPoint(x: view.frame.origin.x - view.frame.size.width / 2.0, y: view.frame.size.height / 2.0)
//                    animation2.toValue = CGPoint(x:  view.frame.origin.x - view.frame.size.width / 2.0, y: view.frame.size.height / 2.0)
//                    animation2.autoreverses = true
//                    view.layer?.add(animation2, forKey: "position")
                    
                case 1:
                    for node in fullprettyRelation.nodes {
                        if node.name == view.text {
//                            let relation = PrettyRelation(nodes: getOneDependency(node))
                            let relation = PrettyRelation(dependency: getDirectDependency(node))
                            relationView.prettyRelation = relation
                            break;
                        }
                    }
                    let size = relationView.prettyRelation.preferredSize
                    relationView.frame = CGRect(x: (scrollView.frame.size.width - size.width) / 2.0,
                                                y: (scrollView.frame.size.height - size.height) / 2.0,
                                                width: size.width,
                                                height: size.height)
                case 2:
                    for node in fullprettyRelation.nodes {
                        if node.name == view.text {
//                            let relation = PrettyRelation(nodes: getAllDependency(node))
                            let relation = PrettyRelation(dependency: getIndirectDependency(node))
                            relationView.prettyRelation = relation
                            break;
                        }
                    }
                    let size = relationView.prettyRelation.preferredSize
                    relationView.frame = CGRect(x: (scrollView.frame.size.width - size.width) / 2.0,
                                                y: (scrollView.frame.size.height - size.height) / 2.0,
                                                width: size.width,
                                                height: size.height)
                case 3:
                    for node in fullprettyRelation.nodes {
                        if node.name == view.text {
//                            let relation = PrettyRelation(nodes: beDependency(node))
                            let relation = PrettyRelation(dependency: getBeDependencied(node))
                            relationView.prettyRelation = relation
                            break;
                        }
                    }
                    let size = relationView.prettyRelation.preferredSize
                    relationView.frame = CGRect(x: (scrollView.frame.size.width - size.width) / 2.0,
                                                y: (scrollView.frame.size.height - size.height) / 2.0,
                                                width: size.width,
                                                height: size.height)
                case 4:
                    for node in fullprettyRelation.nodes {
                        if node.name == view.text {
//                            let relation = PrettyRelation(nodes: beDependency(node))
                            let relation = PrettyRelation(dependency: getDirectAndBeDependencied(node))
                            relationView.prettyRelation = relation
                            break;
                        }
                    }
                    let size = relationView.prettyRelation.preferredSize
                    relationView.frame = CGRect(x: (scrollView.frame.size.width - size.width) / 2.0,
                                                y: (scrollView.frame.size.height - size.height) / 2.0,
                                                width: size.width,
                                                height: size.height)
                default:
                    break
                }
                                
                currentView = view
                
            }
        }
        
    }
    
    func getDirectDependency(_ node: DependencyNode) -> [String: [String]] {
        
        var dependency: [String: [String]] = [node.name: dependencies[node.name]!]
        
        for son in node.sons {
            for node in fullprettyRelation.nodes {
                if node.name == son {
//                    nodes.append(node)
                    dependency[node.name] = dependencies[node.name]!
                    break
                }
            }
        }
        
        return dependency
    }
    
    func getIndirectDependency(_ node: DependencyNode) -> [String: [String]] {
        
        var dependency: [String: [String]] = [node.name: dependencies[node.name]!]
        
        for son in node.sons {
            for node in fullprettyRelation.nodes {
                if node.name == son {
//                    nodes.append(node)
                    dependency[node.name] = dependencies[node.name]!
                    let items = getIndirectDependency(node)
                    for key in items.keys {
                        dependency[key] = dependencies[key]!
                    }
                    
                    break
                }
            }
        }
        
        return dependency
    }
    
    func getBeDependencied(_ node: DependencyNode) -> [String: [String]] {
        
        var dependency: [String: [String]] = [node.name: dependencies[node.name]!]
        
        for n in fullprettyRelation.nodes {
            for son in n.sons {
                if son == node.name {
                    dependency[n.name] = dependencies[n.name]!
                    break
                }
            }
        }
        
        return dependency
    }
    
    func getDirectAndBeDependencied(_ node: DependencyNode) -> [String: [String]] {
        
        var dependency: [String: [String]] = [:]
        
        let directDependency = getDirectDependency(node)
        let beDependencied = getBeDependencied(node)
        
        for (k, v) in directDependency {
            dependency[k] = v
        }
        
        for (k, v) in beDependencied {
            dependency[k] = v
        }
        
        return dependency
    }
    
    func getOneDependency(_ node: DependencyNode) -> [DependencyNode] {
        
        var nodes: [DependencyNode] = [node]
        
        for son in node.sons {
            for node in fullprettyRelation.nodes {
                if node.name == son {
                    nodes.append(node)
                    break
                }
            }
        }
        
        return nodes
    }
    
    func getAllDependency(_ node: DependencyNode) -> [DependencyNode]{
        
        var nodes: [DependencyNode] = [node]
        
        for son in node.sons {
            for node in fullprettyRelation.nodes {
                if node.name == son {
                    nodes.append(contentsOf: getAllDependency(node))
                    break
                }
            }
        }
        
        return nodes
    }
    
    func beDependency(_ node: DependencyNode) -> [DependencyNode]{
        
        var nodes: [DependencyNode] = [node]
        
        for n in fullprettyRelation.nodes {
            for son in n.sons {
                if son == node.name {
                    nodes.append(n)
                    break
                }
            }
        }
        
        return nodes
    }
    
}

class DragView: NSView {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draggingEnded(_ sender: NSDraggingInfo) {
        print("prepareForDragOperation")

        let pboard = sender.draggingPasteboard

        if pboard().pasteboardItems != nil && pboard().pasteboardItems!.count <= 1 {
            // 获得的fileURL大致为 file:///.file/id=123.456
            guard let fileURL = pboard().pasteboardItems?[0].string(forType: .fileURL) else {
                return
            }
            print("fileURL:", fileURL)
            let url = URL.init(string: fileURL)
            // 获得的url大致为 file:///Users/xxx/Downloads/test.txt
            // 如果是是文件夹，大致为 file:///Users/xxx/Downloads/test/
            print("url:", url)
            
            NotificationCenter.default.post(name: Notification.Name("dragEnded"), object: url)
        }
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var searchView: NSSearchField!
    
    @IBOutlet weak var segmentControl: NSSegmentedControl!
    
    @IBOutlet weak var scrollView: NSScrollView!
    
    private let relationView = RelationView()
    
    var currentView: NSView?
    
    var fullprettyRelation: PrettyRelation = PrettyRelation(nodes: [])
    
    var dependencies: [String: [String]] = [:]
    
    @objc func segmentControlListener(){
        searchAction()
    }
    
    // 确认是否接受drag
    
    @IBAction func export(_ sender: Any) {
        saveImage()
    }
    
    @IBAction func reset(_ sender: Any) {
        let visibleRect = self.scrollView.documentVisibleRect;
        let centerPoint = NSMakePoint(NSMidX(visibleRect), NSMidY(visibleRect));
        self.scrollView.animator().setMagnification(1, centeredAt: centerPoint)
    }
    
    @IBAction func small(_ sender: Any) {
//        zoomOut(2)
        
        let magnification = max(self.scrollView.magnification - 0.5, scrollView.minMagnification)
        
        let visibleRect = self.scrollView.documentVisibleRect;
        let centerPoint = NSMakePoint(NSMidX(visibleRect), NSMidY(visibleRect));
        self.scrollView.animator().setMagnification(magnification, centeredAt: centerPoint)
        
//
//
//        let zoomFactor = 2.0
//        let visible = scrollView.documentVisibleRect
//        let newrect = NSInsetRect(visible, NSWidth(visible)*(1 - 1/zoomFactor)/2.0, NSHeight(visible)*(1 - 1/zoomFactor)/2.0);
////        self.scrollView.animator().setMagnification(magnification, centeredAt: newrect.origin)
//        self.scrollView.animator().setMagnification(magnification, centeredAt: CGPoint(x: relationView.frame.midX, y: relationView.frame.midY))
    }
    
    @IBAction func big(_ sender: Any) {
//        zoomIn(2)
        let magnification = min(self.scrollView.magnification + 0.5, scrollView.maxMagnification)
        
        
        let visibleRect = self.scrollView.documentVisibleRect;
        let centerPoint = NSMakePoint(NSMidX(visibleRect), NSMidY(visibleRect));
        self.scrollView.animator().setMagnification(magnification, centeredAt: centerPoint)
        
        
//
//        let zoomFactor = 2.0
//        let visible = scrollView.documentVisibleRect
//        let newrect = NSInsetRect(visible, NSWidth(visible)*(1 - 1/zoomFactor)/2.0, NSHeight(visible)*(1 - 1/zoomFactor)/2.0);
//        self.scrollView.animator().setMagnification(magnification, centeredAt: newrect.origin)
//        self.scrollView.animator().setMagnification(magnification, centeredAt: CGPoint(x: relationView.frame.midX , y: relationView.frame.midY))
        
        
    }
    
    func zoomIn(_ zoomFactor: CGFloat = 1){

            guard let scrollView = self.scrollView else {
                return
            }

            let visible = scrollView.documentVisibleRect
            let newrect = NSInsetRect(visible, NSWidth(visible)*(1 - 1/zoomFactor)/2.0, NSHeight(visible)*(1 - 1/zoomFactor)/2.0);
            let frame = self.relationView.frame

            self.execZoom(docView: self.relationView,
                          size:CGSize(width: zoomFactor, height: zoomFactor),
                          frame:CGRect(x: 0, y: 0, width: frame.size.width * zoomFactor, height: frame.size.height * zoomFactor),
                          origin:newrect.origin)

        }
    
        func zoomOut(_ zoomFactor: CGFloat = 2){
            guard let scrollView = self.scrollView else {
                return
            }
            let visible = scrollView.documentVisibleRect
            let newrect = NSOffsetRect(visible, -NSWidth(visible)*(zoomFactor - 1)/2.0, -NSHeight(visible)*(zoomFactor - 1)/2.0)

            let frame = self.relationView.frame

            self.execZoom(docView: self.relationView,
                          size: CGSize(width: 1/zoomFactor, height: 1/zoomFactor),
                          frame: CGRect(x: 0, y: 0, width: frame.size.width / zoomFactor, height: frame.size.height / zoomFactor),
                          origin: newrect.origin)
        }
    
        func execZoom(docView: NSView, size: CGSize, frame: CGRect, origin: CGPoint){

                docView.scaleUnitSquare(to: size)

                docView.frame = frame

                docView.scroll(origin)

        }
    
    override func scrollWheel(with event: NSEvent) {

            guard event.modifierFlags.contains(.option) else {
                super.scrollWheel(with: event)
                return
            }

            let dy = event.deltaY
            if dy != 0.0 {

                let magnification = self.scrollView.magnification + dy/30
                let point = self.scrollView.contentView.convert(event.locationInWindow, from: nil)

                self.scrollView.setMagnification(magnification, centeredAt: point)
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        NotificationCenter.default.addObserver(forName: Notification.Name("dragEnded"), object: nil, queue: OperationQueue.main) { [weak self] notification in
            if let url = notification.object as? URL,
               let filename = url.absoluteString.replacingOccurrences(of: "file://", with: "").removingPercentEncoding {
                self?.updateWithLockFile(filename: filename)
            }
        }
        self.scrollView.minMagnification = 0.5
        self.scrollView.maxMagnification = 3
        
        segmentControl.segmentCount = 5
        segmentControl.segmentStyle = .roundRect
        segmentControl.setLabel("所有依赖", forSegment: 0)
        segmentControl.setLabel("直接依赖", forSegment: 1)
        segmentControl.setLabel("间接依赖", forSegment: 2)
        segmentControl.setLabel("被依赖", forSegment: 3)
        segmentControl.setLabel("直接依赖 + 被依赖", forSegment: 4)
        segmentControl.setWidth(100, forSegment: 0)
        segmentControl.setWidth(100, forSegment: 1)
        segmentControl.setWidth(100, forSegment: 2)
        segmentControl.setWidth(100, forSegment: 3)
        segmentControl.setWidth(160, forSegment: 4)
        segmentControl.selectedSegment = 0
        segmentControl.trackingMode = .selectOne
        segmentControl.target = self
        segmentControl.action = #selector(segmentControlListener)

        let searchCell = searchView.cell as! NSSearchFieldCell
        let searchButtonCell = searchCell.searchButtonCell
        searchButtonCell?.target = self
        searchButtonCell?.action = #selector(searchAction)

        
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.documentView = relationView
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleOpenFile(notification:)), name: NSNotification.Name(rawValue: OCTOpenFileNotification), object: nil)
     //   FileName = "/Users/jzd/Downloads/Lumiere/Podfile.lock"
        if FileName.count > 0 {
            
            updateRelationView(filename: FileName)
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        guard !relationView.frame.equalTo(CGRect()) else {
            return
        }
        
        let size = relationView.prettyRelation.preferredSize
        let parentSize = scrollView.frame.size
        relationView.frame = CGRect(x: 0,
                                    y: 0,
                                    width: max(size.width, parentSize.width),
                                    height: max(size.height, parentSize.height))
    }
    
    
    @objc func handleOpenFile(notification: Notification) {
        
        guard let filename = notification.object as? String else {
            return
        }
        
        updateRelationView(filename: filename)
    }
    
    func updateRelationView(filename: String) {
        
        view.window?.title = filename
        if filename.hasSuffix(".lock") {
            updateWithLockFile(filename: filename)
        } else {
            updateWithDataFile(filename: filename)
        }
    }
    
    func updateWithLockFile(filename: String) {
        do {
            let string = try String(contentsOfFile: filename, encoding: .utf8)
            if let dependency = Parser().parse(string) {
                // print(dependency)
                relationView.prettyRelation = PrettyRelation(dependency: dependency)
                dependencies = dependency
                fullprettyRelation = relationView.prettyRelation
            } else {
                alert(title: "Error", msg: "Parse Error: Wrong Format")
            }
        } catch {
            
            alert(title: "Error", msg: error.localizedDescription)
        }
    }
    
    
    func updateWithDataFile(filename: String) {
        
        do {
            
            let url = URL(fileURLWithPath: filename)
            let data = try Data(contentsOf: url)
            let relation = try JSONDecoder().decode(PrettyRelation.self, from: data)
            relationView.prettyRelation = relation
            fullprettyRelation = relationView.prettyRelation
        } catch {
            
            alert(title: "Error", msg: error.localizedDescription)
        }
    }
    
    
    func alert(title: String, msg: String) {

        
        let alert = NSAlert()
        
        
        alert.addButton(withTitle: "Ok")
        alert.messageText = title
        alert.informativeText = msg
        alert.alertStyle = .warning
        alert.runModal()
    }

}

