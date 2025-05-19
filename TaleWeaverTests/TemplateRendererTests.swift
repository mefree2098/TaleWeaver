import XCTest
@testable import TaleWeaver

class TemplateRendererTests: XCTestCase {
    func testRenderSinglePlaceholder() {
        let template = "Hello, {{name}}!"
        let context = ["name": "Alice"]
        let output = TemplateRenderer.render(template: template, context: context)
        XCTAssertEqual(output, "Hello, Alice!")
    }

    func testRenderMultiplePlaceholders() {
        let template = "{{greeting}}, {{name}}! Today is {{day}}."
        let context = ["greeting": "Hi", "name": "Bob", "day": "Monday"]
        let output = TemplateRenderer.render(template: template, context: context)
        XCTAssertEqual(output, "Hi, Bob! Today is Monday.")
    }

    func testRenderMissingKeyLeavesEmpty() {
        let template = "Hello, {{unknown}}!"
        let context: [String:String] = [:]
        let output = TemplateRenderer.render(template: template, context: context)
        XCTAssertEqual(output, "Hello, !")
    }

    func testRenderIgnoresWhitespaceInsideBraces() {
        let template = "{{ greeting }} buddies"
        let context = ["greeting": "Hey there"]
        let output = TemplateRenderer.render(template: template, context: context)
        XCTAssertEqual(output, "Hey there buddies")
    }

    func testRenderNoPlaceholdersUnchanged() {
        let template = "Just text."
        let output = TemplateRenderer.render(template: template, context: [:])
        XCTAssertEqual(output, "Just text.")
    }
}