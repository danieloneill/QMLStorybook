import QtQuick 2.15

MButton {
    id: button

    checkable: true
    //leftPadding: cbImage.width
    horizontalAlignment: Text.AlignLeft

    leftPadding: 28
    image.source: checked ? imageOn : imageOff
    image.anchors {
        left: image.parent.left
        centerIn: undefined
        verticalCenter: image.parent.verticalCenter
        verticalCenterOffset: -2
        leftMargin: 5
    }

    // <mars>/www/images/icons/check-on.png
    property string imageOn:  'data:;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAAEEfUpiAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAc5JREFUWMPllr8vREEQxz937zg5ESG5BolK5MQfoNArFP4BKpVEq1FrNGgUOteJUqJQKNQaCRKN4k7DNUSCI++sZl6yWbvvtxMxyWZ/zOzMd+d9Z99ChKiiDG4AZbUI3X+rT6aDQeB0kRiigKEw5TcEs7I4o0MsyMS3ePE0fXLxdAwqKkUqTFk0FKNA3eVORX2SOZuyIAYdi66UJQUXwKe+6MdswTkmk1EL5sXmMi43PW18KvpqWDB9sSHzliP1sRAEG5+ibF2fIj1N/4RsAU1gPc3mY0nilZksPwGNO7bktyM2Dmiftu0q6DB5lr5iKuI42JR+BXhzGZlH6JV+XGA/RB03WJww+P9ioXk7CkHg4ED65bQOlHnr2BzYkriqjUfiMsyEteG6ZeMcIVGwgJLlBHT2cy1Nr4vXQL/Eq0ltPXYjaAU4Mah1BvR0I/iOEbgJjIVd/uoHwbwDfTZF0WJYyNDMt81+EpQqYT2ZBGto6X4FppL6TQugBnxowY/S+nUZVoFd4F7eObpsG0RbyHIwm+GgEUABa6I71NZawHDWzLoM9ywg9HYe8ZTKhQPXjuD1PLkVZlgG7owf5VLe1ZWlDFP7LfLLUrKkWvGf5Au6XLzxCAl5RwAAAABJRU5ErkJggg=='

    // <mars>/www/images/icons/check-off.png
    property string imageOff: 'data:;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAAEEfUpiAAAABGdBTUEAALGPC/xhBQAAAAlwSFlzAAAuIwAALiMBeKU/dgAAAMNJREFUWMPtl00KwjAQRl9KwZ+N19C9G8GdHsPbicdwp+suvYVbXVkXTkFCmww61CLzwRBok8lj8oUhkFFdxF8KhqZahVXKeOoBpktZyB4mBIE8t/xbm5QgaEqRWKerZWru1x79gwSul0ZiDm3s41MIwFHGXCxiG7sTPYFJgqZ9LZUtbAJc/Pab6v1mz9oalpHuEp0AY+AGXIHKcOMpsAIOwC7lwkYVsDUEmOdc+/O26AAO4AAOUEbvjs0HDx6NHoPthk+5aiLJg8hZhgAAAABJRU5ErkJggg=='
}
