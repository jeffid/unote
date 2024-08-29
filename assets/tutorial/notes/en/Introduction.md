---
title: Introduction
tags: [Basics, Notebooks/Tutorial]
created: '2024-06-01T00:00:00.000Z'
updated: '2024-06-01T00:00:00.000Z'
---

# Introduction

## The Data Directory

You can also change the data directory at any time via `Settings -> Data Directory`, the current content won't be copied over to the new one.

## The Main Page

The main page shows you all notes contained in the currently active category, properly ordered and filtered by the search query.

### Notes

Notes will have some badges if they are pinned, favorite or encryption.
Pinned notes are displayed before the others.

If you long-press them you can access some commands, all of them are also available by sliding a note to the side, most of them are also available from the editor's toolbar.

## The Sidebar

It can be opened by clicking the hamburger icon in the top left corner.

The sidebar lists all your tags and you can access the Settings from there.

### Categories

- **All Notes**: This section contains all notes.
- **Favorites**: This section contains all notes you've favorite.
- **Untagged**: This section contains all notes that have no tags.
- **Trash**: This section contains all notes that have been deleted. These notes won't be displayed in any other category.
- **#**: Virtual tags
- All your other tags
  
### Tags

Notes can have multiple tags, which are useful for better categorization.

#### Syntax

- **Root**: Root tags don't contain any forward slash (`/`), they will be rendered in the sidebar.
- **Nested**: Tags can also be nested, _indefinitely_, just write them like a path, separating the levels with a forward slash: `foo/bar/baz`.

#### Editing

There are multiple ways to add/remove tags:

- **Single-note editing**: You can edit a note's tags via the popup menu in the toolbar.
- **Multi-note editing**: Tags can be added/removed from multiple notes at once via the [multi-note editing](@note/07 - Multi-Note Editing.md) features provided.
- **Advanced search & replace**: Alternatively you could just open your data directory with your editor and perform a search & replace there, this way you can also use advanced features like regexes.

## Encryption

The editor uses AES-GCM (Advanced Encryption Standard-Galois /Counter Mode) algorithm to encrypt the document content, which has the characteristics of efficient encryption and decryption and support data integrity verification.

To enable document encryption, you must do so from the pop-up menu in the upper right corner of the edit screen.

## Noting

Documents saved through this editor include a piece of metadata at the beginning to record labels, modification dates, etc.

```yaml
---
title: Introduction
tags: [Basics, Notebooks/Tutorial]
created: '2024-06-01T00:00:00.000Z'
updated: '2024-06-01T00:00:00.000Z'
---
```

## Feedback

Feel free to [contact us](https://github.com/inote-flutter/inote/issues) about any issues you may encounter, any features suggestions and generally sharing your opinion about iNote and how we can improve it.

Have a nice day!
