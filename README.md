# DGDrawingLabel
Custom label which allows to pre-calculate text layout. It can be used in table views and collection views to achieve high-performance scroll when cell heights are different and depend on text size.

## Requirements
* Xcode 6 or higher
* Apple LLVM compiler
* iOS 8.0 or higher (May work on previous versions, just did not testit. Feel free to edit it).
* ARC

## Demo

Build and run the DGDrawingLabelExample project in Xcode to see DGDrawingLabel in action and how it helps with dynamic cells in table view.

## Installation

### Cocoapods

In progress...

### Manual install

All you need to do is drop DGDrawingLabel files into your project, and add include headers to the top of classes that will use it.

## Example usage

``` objective-c
// Addint label to view
DGDrawingLabel *textLabel = [[DGDrawingLabel alloc] init];
textLabel.backgroundColor = [UIColor whiteColor];
[self.view addSubview:textLabel];
        
NSRange range = NSMakeRange(0, 5);
DGDrawingLabelAttributedRange *attributedRange = [[DGDrawingLabelAttributedRange alloc] initWithAttributes:@{NSForegroundColorAttributeName : [UIColor redColor], NSFontAttributeName : [UIFont boldSystemFontOfSize:20]} range:range];
NSArray *attributedRanges = @[attributedRange];

// Calculating layout
textLabel.precalculatedLayout = [DGDrawingLabel calculateLayoutWithText:@"text goes here"
                                                                   font:[UIFont systemFontOfSize:16.0f]
                                                          textAlignment:NSTextAlignmentCenter
                                                              textColor:[UIColor grayColor]
                                                               maxWidth:self.view.bounds.size.width
                                                       attributedRanges:attributedRanges];
                                                               
// Calculating and setting frame. On  setFrame it will call setNeedsDisplay and will draw text using precalculated layout.
CGRect frame = CGRectZero;
frame.size = textLabel.precalculatedLayout.size;
textLabel.frame = frame;
```

For more complex usage see example project. It shows how to use it to achieve high-performance scroll with dynamic cells.

## TODO

* Add support for NSBackgroundColorAttributeName;
* Detect URLs / hashtags / usernames.

## Contact

Danil Gontovnik

- https://github.com/gontovnik
- https://twitter.com/gontovnik
- http://gontovnik.com/
- gontovnik.danil@gmail.com

## License

The MIT License (MIT)

Copyright (c) 2015 Danil Gontovnik

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
