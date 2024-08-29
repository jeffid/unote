---
title: Markdown Syntax
tags: [Basics, Notebooks/Tutorial]
created: '2024-06-01T00:00:00.000Z'
updated: '2024-06-01T00:00:00.000Z'
---

# Markdown Syntax

# Heading 1
## Heading 2               
### Heading 3
#### Heading 4
##### Heading 5
###### Heading 6

# Heading 1 link [Heading link](https://github.com/inote-flutter "Heading link")
## Heading 2 link [Heading link](https://github.com/inote-flutter "Heading link")
### Heading 3 link [Heading link](https://github.com/inote-flutter "Heading link")
#### Heading 4 link [Heading link](https://github.com/inote-flutter "Heading link") 
##### Heading 5 link [Heading link](https://github.com/inote-flutter "Heading link")
###### Heading 6 link [Heading link](https://github.com/inote-flutter "Heading link")


This is an H1 (underline syntax)
=============

This is an H2
-------------

# Other Syntax

### Character style

----

~~strikethrough~~ <s>strikethrough（HTML tag）</s>
*italic*      _italic_
**bold**  __bold__
***bold italic*** ___bold italic___

subscript: X<sub>2</sub> superscript: O<sup>2</sup>

**abbreviation(HTML abbr tag)**

The <abbr title="Hyper Text Markup Language">HTML</abbr> specification is maintained by the <abbr title="World Wide Web Consortium">W3C</abbr>.

### Blockquotes

> Blockquotes

### Links and anchors

[link](http://localhost/)

[link with alter text](http://localhost/ "alter text")

direct link：<https://github.com/inote-flutter>

[anchor][anchor-id]

[anchor-id]: https://github.com/inote-flutter

[mailto:test.test@gmail.com](mailto:test.test@gmail.com)

### Codes highlighting

#### Inline code

command line：`npm install marked`

#### intent style

Indent four Spaces to perform a function similar to a `<pre>` Preformatted Text.

    <?php
        echo "Hello world!";
    ?>

Preformatted text:

    | First Header  | Second Header |
    | ------------- | ------------- |
    | Content Cell  | Content Cell  |
    | Content Cell  | Content Cell  |

#### JS code block

```javascript
function test() {
	console.log("Hello world!");
}
 
(function(){
    var box = function() {
        return box.fn.init();
    };

    box.prototype = box.fn = {
        init : function(){
            console.log('box.init()');

			return this;
        },

		add : function(str) {
			alert("add", str);

			return this;
		},

		remove : function(str) {
			alert("remove", str);

			return this;
		}
    };
    
    box.fn.init.prototype = box.fn;
    
    window.box =box;
})();

var testBox = box();
testBox.add("jQuery").remove("jQuery");
```

#### HTML codes

```html
<!DOCTYPE html>
<html>
    <head>
        <mate charest="utf-8" />
        <meta name="keywords" content="Editor.md, Markdown, Editor" />
        <title>Hello world!</title>
        <style type="text/css">
            body{font-size:14px;color:#444;font-family: "Microsoft Yahei", Tahoma, "Hiragino Sans GB", Arial;background:#fff;}
            ul{list-style: none;}
            img{border:none;vertical-align: middle;}
        </style>
    </head>
    <body>
        <h1 class="text-xxl">Hello world!</h1>
        <p class="text-green">Plain text</p>
    </body>
</html>
```

### Images

Image:
![](https://avatars.githubusercontent.com/u/176027501 "iNote logo")
> iNote logo

Image + Link ：
[![](https://avatars.githubusercontent.com/u/176027501 "iNote logo")](https://github.com/inote-flutter/inote "iNote")

----

### Lists

#### Unordered Lists (-)

- A
- B
- C

#### Unordered Lists (*)

* A
* B
* C

#### Unordered nested Lists (+)

+ A
+ B
    + AA
    + BB
    + CC
+ C
    * AA
    * BB
    * CC

#### Ordered Lists

1. A
2. B
3. C

#### GFM task list

- [x] GFM task list 1
- [x] GFM task list 2
- [ ] GFM task list 3
    - [ ] GFM task list 3-1
    - [ ] GFM task list 3-2
    - [ ] GFM task list 3-3
- [ ] GFM task list 4
    - [ ] GFM task list 4-1
    - [ ] GFM task list 4-2

----

### Tables

| name        | price  | quantity|
| --------    | -----: | :----:  |
| PC          | $1600  |   5     |
| phone       |   $12  |   12    |

First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell 

| First Header  | Second Header |
| ------------- | ------------- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |

| Function name | Description                    |
| ------------- | ------------------------------ |
| `help()`      | Display the help window.       |
| `destroy()`   | **Destroy your computer!**     |

| Left-Aligned  | Center Aligned  | Right Aligned |
| :------------ |:---------------:| -----:|
| col 3 is      | some wordy text | $1600 |
| col 2 is      | centered        |   $12 |
| zebra stripes | are neat        |    $1 |

| Item      | Value |
| --------- | -----:|
| Computer  | $1600 |
| Phone     |   $12 |
| Pipe      |    $1 |

----

#### HTML Entities Codes

&copy; &  &uml; &trade; &iexcl; &pound;
&amp; &lt; &gt; &yen; &euro; &reg; &plusmn; &para; &sect; &brvbar; &macr; &laquo; &middot; 

X&sup2; Y&sup3; &frac34; &frac14;  &times;  &divide;   &raquo;

18&ordm;C  &quot;  &apos;

[========]

### Emoji :smiley:

> Blockquotes :star:

#### GFM task lists & Emoji & fontAwesome icon emoji & editormd logo emoji :editormd-logo-5x:

- [x] :smiley: @mentions, :smiley: #refs, [links](), **formatting**, and <del>tags</del> supported :editormd-logo:;
- [x] list syntax required (any unordered or ordered list supported) :editormd-logo-3x:;
- [x] [ ] :smiley: this is a complete item :smiley:;
- [ ] []this is an incomplete item [test link](#) :fa-star: @pandao; 
- [ ] [ ]this is an incomplete item :fa-star: :fa-gear:;
    - [ ] :smiley: this is an incomplete item [test link](#) :fa-star: :fa-gear:;
    - [ ] :smiley: this is  :fa-star: :fa-gear: an incomplete item [test link](#);

#### Backslash Escape

\*literal asterisks\*

[========]

### Scientific formula TeX(KaTeX)

$$E=mc^2$$

inline formula$$E=mc^2$$inline formula, $$E=mc^2$$.

$$x > y$$

$$(\sqrt{3x-1}+(1+x)^2)$$

$$\sin(\alpha)^{\theta}=\sum_{i=0}^{n}(x^i + \cos(f))$$

多行公式：

```math
\displaystyle
\left( \sum\_{k=1}^n a\_k b\_k \right)^2
\leq
\left( \sum\_{k=1}^n a\_k^2 \right)
\left( \sum\_{k=1}^n b\_k^2 \right)
```

```katex
\displaystyle 
    \frac{1}{
        \Bigl(\sqrt{\phi \sqrt{5}}-\phi\Bigr) e^{
        \frac25 \pi}} = 1+\frac{e^{-2\pi}} {1+\frac{e^{-4\pi}} {
        1+\frac{e^{-6\pi}}
        {1+\frac{e^{-8\pi}}
         {1+\cdots} }
        } 
    }
```

```latex
f(x) = \int_{-\infty}^\infty
    \hat f(\xi)\,e^{2 \pi i \xi x}
    \,d\xi
```

### End
