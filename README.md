# QMLStorybook
A simple "Storybook" for my QML components.

![QMLStorybook Screenshot](https://user-images.githubusercontent.com/10540429/202076390-0c6d7708-a9a6-464b-a521-8d44c689a9b7.png)

This is for making a (relatively) quick layout of your controls/components.

It's possible to instantiate a component several times with different properties.

## Defining a Control/Component

Any .qml file beginning with a capital letter which can be generally instantiated can be used.

*[controls/Storybook.qml](/controls/Storybook.qml)* contains some example control files and entries.

Entries must define:
 * A **name** (to identify it in the list)
 * An **instances** array, which may contain only a single empty object ({}) to see a default instance

and optionally:
 * A **bindSignals** callback, intended to bind signals from the instance object (*obj*) to some sort of feedback
 * A **notes** string containing markdown content

```
        { 'name':'MCheckBox',
            'source':'MCheckBox.qml',
            'instances': [
                { 'properties':{'text':'MCheckBox'} }
            ],
            'bindSignals': function(obj) {
                obj.checkedChanged.connect( function() { storybook.log(`Checkbox checked: ${obj.checked}`); } );
            },
            'notes': "**MCheckBox** inherits **MButton** and reuses the signals and properties therein."
        }
```

*MCheckBox* doesn't show the text property on its face. This is a bug, and most of the reason I made this ... Storybook-like ... app ... whatever it is.

*MCalendar* sometimes doesn't size its children (the days) based on the layout. This is also a bug, and another cool reason to have this.

*MButton* works properly though, I'm pretty sure, but as you can see in the Storybook.qml entry for it, I don't yet test out all the property options.

## Demo?

Although it's painfully close to pure QML, I use a QFile method from the C++ side to load file source into the **Source** tab. This makes loading it in [Canonic](https://www.canonic.com/) not possible, so for as long as I keep paying the server tab you can try it here:

[https://oneill.app/storybook/](https://oneill.app/storybook/)

On Webassembly the text and lines look pretty jaggy. I suspect it's a Qt 6.4 thing. (On Desktop it doesn't look gross like that.)
