# Te|stMd
**Mastering Markdown** 3 minute read  [Download PDF version](https://guides.github.com/pdfs/markdown-cheatsheet-online.pdf)

1. [Intro](https://guides.github.com/features/mastering-markdown/#intro)
2. What What What[What is Markdown?](https://guides.github.com/features/mastering-markdown/#what) What What What [What is Markdown?](https://guides.github.com/features/mastering-markdown/#what) What What What
3. [Examples](https://guides.github.com/features/mastering-markdown/#examples)
4. [Basic syntax](https://guides.github.com/features/mastering-markdown/#syntax)
5. **[GFM](https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown)**

Markdown `,:-/` is a `lightweight` and easy-to-use syntax for styling all forms of writing on the `GitHub` platform.
You can create tables by assembling a list of words and dividing them with hyphens `-` (for the first row), and then separating each column with a pipe `|`:


1.  [Gists](https://gist.github.com/)
2.  Comments in Issues and Pull Requests
3.  Files with the `.md` or `.markdown` extension
- [Gists](https://gist.github.com/)
- Comments in Issues and Pull Requests
- Files with the `.md` or `.markdown` extension


**What you will learn:**

- How the Markdown format makes styled collaborative editing easy
- How Markdown differs from traditional formatting approaches
- How to use Markdown to format text
- How to leverage GitHub’s automatic Markdown rendering
- How to apply GitHub’s unique Markdown extensions

**What is M|arkdown?**

*ssdsdsddwdwd|d*

 ```gcc|cg``` 

 
```gcccg```
 Markdown *is* just regular *text* with a few non-alphabetic characters thrown in, like `#` or `*`.

Markdown is a way to style text on the web.[Markdown](http://daringfireball.net/projects/markdown/) is a way to style text on the web.[Markdown](http://daringfireball.net/projects/markdown/) is a way to style text on the web.[Markdown](http://daringfireball.net/projects/markdown/) is a way to style text on the web.

[Markdown](http://daringfireball.net/projects/markdown/) is a way to style text on the web. You control the display of the document; formatting words as bold or italic, adding images, and creating lists are just a few of the things we can do with Markdown. ``Mostly``, Markdown ```is``` just regular text with a few non-alphabetic characters thrown in, like `#` or `*`.

You can use Markdown most places around GitHub:

- [Gists](https://gist.github.com/)
- Comments in Issues and Pull Requests
- Files with the `.md` or `.markdown` extension

For more information, see “[Writing on GitHub](https://help.github.com/categories/writing-on-github/)” in the *GitHub Help*.

## **Examples**

- **[Text](https://guides.github.com/features/mastering-markdown/#)**
- **[Lists](https://guides.github.com/features/mastering-markdown/#)**
- **[Images](https://guides.github.com/features/mastering-markdown/#)**
- **[Headers & Quotes](https://guides.github.com/features/mastering-markdown/#)**
- **[Code](https://guides.github.com/features/mastering-markdown/#)**
- **[Extras](https://guides.github.com/features/mastering-markdown/#)**

```
It's very easy to make some words **bold** and other words *italic* with Markdown. You can even [link to Google!](http://google.com)

```

It's very easy to make some words **bold** and other words *italic* with Markdown. You can even [link to Google!](http://google.com/)

## **Syntax guide**

Here’s an overview of Markdown syntax that you can use anywhere on GitHub.com or in your own text files.

### **Headers**

`# This is an <h1> tag
## This is an <h2> tag
###### This is an <h6> tag`

### **Emphasis**

- `This text will be italic
This willalso be italicThis
    text will be bold
    This will also be bold 
    you can combine the`
- This text will be italicThis will
    also be italicThis 
    text will be bold
    This will also be bold 
    you can combine the
- xsxxsxsxsxs

- `This text will be italic*
_This will also be italic_
**This text will be bold**
__This will also be bold__
_You **can** combine them_`

### **Lists**

### **Unordered**


- `Item 1
- aa
* bb
+ cc
* Item 2 * Item 2a * Item 2b`

### Ordered

`1. Item 1
1. Item 2
1. Item 3
   1. Item 3a
   1. Item 3b`

### **Images**

`![GitHub Logo](/images/logo.png)
Format: ![Alt Text](url)`

### **Links**

`http://github.com - automatic!
[GitHub](http://github.com)`

### **Blockquotes**

`As Kanye West said:

> We're living the future so
> the present is our past.`

### **Inline code**

`I think you should use an
`<addr>` element here instead.`

## **GitHub Flavored Markdown**

GitHub.com uses its own version of the Markdown syntax that provides an additional set of useful features, many of which make it easier to work with content on GitHub.com.

Note that some features of GitHub Flavored Markdown are only available in the descriptions and comments of Issues and Pull Requests. These include @mentions as well as references to SHA-1 hashes, Issues, and Pull Requests. Task Lists are also available in Gist comments and in Gist Markdown files.

### **Task Lists**

- `@mentions, #refs, [links](), **formatting**, and <del>tags</del> supported
- list syntax required (any unordered or ordered list supported)
- this is a complete item
- this is an incomplete item`

If you include a task list in the first comment of an Issue, you will get a handy progress indicator in your issue list. It also works in Pull Requests!

### **Tables**

You can create tables by assembling a list of words and dividing them with hyphens `-` (for the first row), and then separating each column with a pipe `|`:

`First Header | Second Header
------------ | -------------
Content from cell 1 | Content from cell 2
Content in the first column | Content in the second column`

Would become:

[Untitled](https://www.notion.so/42bba4a8d94446c4882a5bfeede40c6b)

### **SHA references**

Any reference to a commit’s [SHA-1 hash](http://en.wikipedia.org/wiki/SHA-1) will be automatically converted into a link to that commit on GitHub.

`16c999e8c71134401a78d4d46435517b2271d6ac
mojombo@16c999e8c71134401a78d4d46435517b2271d6ac
mojombo/github-flavored-markdown@16c999e8c71134401a78d4d46435517b2271d6ac`

### **Issue references within a repository**

Any number that refers to an Issue or Pull Request will be automatically converted into a link.

`#1
mojombo#1
mojombo/github-flavored-markdown#1`

### **Username @mentions**

Typing an `@` symbol, followed by a username, will notify that person to come and view the comment. This is called an “@mention”, because you’re *mentioning* the individual. You can also @mention teams within an organization.

### **Automatic linking for URLs**

Any URL (like `http://www.github.com/`) will be automatically converted into a clickable link.

### **Strikethrough**

Any word wrapped with two tildes (like `~~this~~`) will appear crossed out.
### **Emoji**
GitHub supports [emoji](https://help.github.com/articles/basic-writing-and-formatting-syntax/#using-emoji)!

To see a list of every image we support, check out the [Emoji Cheat Sheet](https://github.com/ikatyang/emoji-cheat-sheet/blob/master/README.md).

### **Syntax highlighting**

Here’s an example of how you can use syntax highlighting with [GitHub Flavored Markdown](https://help.github.com/articles/basic-writing-and-formatting-syntax/):

````javascript
function fancyAlert(arg) {
  if(arg) {
    $.facebox({div:'#foo'})
  }
}
````

You can also simply indent your code by four spaces:

    `function fancyAlert(arg) {
      if(arg) {
        $.facebox({div:'#foo'})
      }
    }`

Here’s an example of Python code without syntax highlighting:

`def foo():
    if not bar:
        return True`


Last updated Sep 18, 2021
### Table 1

| `Sequence` | What does it do? |
| -------- | ---------------- |
| `\033[m`  | Reset text formatting and colors.
| `\033[1m` | Bold text. |
| `\033[2m` | Faint text. |
| `\033[3m` | Italic text. |
| `\033[4m` | Underline text. |
| `\033[5m` | Slow blink. |
| `\033[7m` | Swap foreground and background colors. |
| `\033[8m` | Hidden text. |
| `\033[9m` | Strike-through text. |

### Table 2

表头1  | 表头2  | abc
----  | ----  | ---
单元格  | 单元格 
单元格  | 单元格


### Table 3

| pattern | Matchess |
| --- | --- |
| `*` | Every file in the current directory |
`?` | Files consisting of one character
`??` | Files consisting of two characters
`??*` | Files consisting of two or more characters
`[abcdefg]` | Files consisting of a single letter from a to g.
`[gfedcba]` | Same as above
`[a-g]` | Same as above
`[a-cd-g]` | Same as above
`[a-zA-Z0-9]` |  Files that consist of a single letter or number
`[!a-zA-Z0-9]` | Files that consist of a single character not a letter or number
`[a-zA-Z]*` | Files that start with a letter
`?[a-zA-Z]*` | Files whose second character matches a letter.
`*[0-9]` | Files that end with a number
`?[0-9]` | Two character filename that end with a number
`*.[0-9]` | Files that end with a dot and a number

### Table 3

表头1  | 表头2  | abc
----  | ----  | ---
单元格  | 单元格 
单元格  | 单元格
