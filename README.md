# Pablo

Pablo is a barebones NSLocalizedString extractor for your Xcode projects.

## Usage

`-p` specifies the path to the xcode project

By default it will output a valid strings file, which can easily be piped to disk.

```ruby
ruby pablo.rb -p ~/Path_to_xcproj/ProjectS.xcodeproj > localizable.strings
```
