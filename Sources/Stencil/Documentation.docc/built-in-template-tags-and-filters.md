# Built-in Template Tags and Filters

## Built-in Tags

### for

A for loop allows you to iterate over an array found by variable lookup.

```html
<ul>
  {% for user in users %}
    <li>{{ user }}</li>
  {% endfor %}
</ul>
```

The `for` tag can iterate over dictionaries.

```html
<ul>
  {% for key, value in dict %}
    <li>{{ key }}: {{ value }}</li>
  {% endfor %}
</ul>
```
    
It can also iterate over ranges, tuple elements, structs' and classes' stored properties (using `Mirror`).

You can iterate over range literals created using `N...M` syntax, both in ascending and descending order:

```html
<ul>
  {% for i in 1...array.count %}
    <li>{{ i }}</li>
  {% endfor %}
</ul>
```

The `for` tag can contain optional `where` expression to filter out elements on which this expression evaluates to false.

```html
<ul>
  {% for user in users where user.name != "Kyle" %}
    <li>{{ user }}</li>
  {% endfor %}
</ul>
```

The `for` tag can take an optional `{% empty %}` block that will be displayed if the given list is empty or could not be found.

```html
<ul>
  {% for user in users %}
    <li>{{ user }}</li>
  {% empty %}
    <li>There are no users.</li>
  {% endfor %}
</ul>
```

The for block sets a few variables available within the loop:

- `first` - True if this is the first time through the loop
- `last` - True if this is the last time through the loop
- `counter` - The current iteration of the loop (1 indexed)
- `counter0` - The current iteration of the loop (0 indexed)
- `length` - The total length of the loop

For example:

```html
{% for user in users %}
  {% if forloop.first %}
    This is the first user.
  {% endif %}
{% endfor %}
```

```html
{% for user in users %}
  This is user number {{ forloop.counter }} user.
{% endfor %}
```

The `for` tag accepts an optional label, so that it may later be referred to by name. The contexts of parent labeled loops can be accessed via the `forloop` property:

```html
{% outer: for item in users %}
  {% for item in 1..3 %}
    {% if forloop.outer.first %}
      This is the first user.
    {% endif %}
  {% endfor %}
{% endfor %}
```

### break

The `break` tag lets you jump out of a for loop, for example if a certain condition is met:

```html
{% for user in users %}
  {% if user.inaccessible %}
    {% break %}
  {% endif %}
  This is user {{ user.name }}.
{% endfor %}
```

Break tags accept an optional label parameter, so that you may break out of multiple loops:

```html
{% outer: for user in users %}
  {% for address in user.addresses %}
    {% if address.isInvalid %}
      {% break outer %}
    {% endif %}
  {% endfor %}
{% endfor %}
```

### continue

The `continue` tag lets you skip the rest of the blocks in a loop, for example if a certain condition is met:

```html
{% for user in users %}
  {% if user.inaccessible %}
    {% continue %}
  {% endif %}
  This is user {{ user.name }}.
{% endfor %}
```

Continue tags accept an optional label parameter, so that you may skip the execution of multiple loops:

```html
{% outer: for user in users %}
  {% for address in user.addresses %}
    {% if address.isInvalid %}
      {% continue outer %}
    {% endif %}
  {% endfor %}
{% endfor %}
```

### if

The `{% if %}` tag evaluates a variable, and if that variable evaluates to true the contents of the block are processed. Being true is defined as:

- Present in the context
- Being non-empty (dictionaries or arrays)
- Not being a false boolean value
- Not being a numerical value of 0 or below
- Not being an empty string

```html
{% if admin %}
  The user is an administrator.
{% elif user %}
  A user is logged in.
{% else %}
  No user was found.
{% endif %}
```

## Operators

`if` tags may combine `and`, `or` and `not` to test multiple variables or to negate a variable.

```html
{% if one and two %}
    Both one and two evaluate to true.
{% endif %}

{% if not one %}
    One evaluates to false
{% endif %}

{% if one or two %}
    Either one or two evaluates to true.
{% endif %}

{% if not one or two %}
    One does not evaluate to false or two evaluates to true.
{% endif %}
```

You may use `and`, `or` and `not` multiple times together. `not` has
higest precedence followed by `and`. For example:

```html
{% if one or two and three %}
```

Will be treated as:

```
one or (two and three)
```

You can use parentheses to change operator precedence. For example:

```html
{% if (one or two) and three %}
```

Will be treated as:

```
(one or two) and three
```

### == operator

```html
{% if value == other_value %}
  value is equal to other_value
{% endif %}
```

> The equality operator only supports numerical, string and boolean types.

### != operator

```html
{% if value != other_value %}
  value is not equal to other_value
{% endif %}
```

> The inequality operator only supports numerical, string and boolean types.

### < operator

```html
{% if value < other_value %}
  value is less than other_value
{% endif %}
```

> The less than operator only supports numerical types.

### <= operator

```html
{% if value <= other_value %}
  value is less than or equal to other_value
{% endif %}
```

> The less than equal operator only supports numerical types.

### > operator

```html
{% if value > other_value %}
  value is more than other_value
{% endif %}
```

> The more than operator only supports numerical types.

### >= operator

```html
{% if value >= other_value %}
  value is more than or equal to other_value
{% endif %}
```

> The more than equal operator only supports numerical types.

### ifnot

> `{% ifnot %}` is deprecated. You should use `{% if not %}`.

```html
{% ifnot variable %}
  The variable was NOT found in the current context.
{% else %}
  The variable was found.
{% endif %}
```

### now

### filter

Filters the contents of the block.

```html
{% filter lowercase %}
  This Text Will Be Lowercased.
{% endfilter %}
```

You can chain multiple filters with a pipe (`|`).

```html
{% filter lowercase|capitalize %}
  This Text Will First Be Lowercased, Then The First Character Will BE
  Capitalised.
{% endfilter %}
```

### include

You can include another template using the `include` tag.

```html
{% include "comment.html" %}
```

By default the included file gets passed the current context. You can pass a sub context by using an optional 2nd parameter as a lookup in the current context.

```html
{% include "comment.html" comment %}
```

The `include` tag requires you to provide a loader which will be used to lookup the template.

```swift
let environment = Environment(bundle: [Bundle.main])
let template = environment.loadTemplate(name: "index.html")
```

### extends

Extends the template from a parent template.

```html
{% extends "base.html" %}
```

See [Template Inheritance](/Template Language#Template inheritance) for more information.

### block

Defines a block that can be overridden by child templates. See [Template Inheritance](/Template Language#Template inheritance) for more information.

## Built-in Filters

### capitalize

The capitalize filter allows you to capitalize a string. For example, `stencil` to `Stencil`. Can be applied to array of strings to change each string.

```html
{{ "stencil"|capitalize }}
```

### uppercase

The uppercase filter allows you to transform a string to uppercase. For example, `Stencil` to `STENCIL`. Can be applied to array of strings to change each string.

```html
{{ "Stencil"|uppercase }}
```

### lowercase

The uppercase filter allows you to transform a string to lowercase. For example, `Stencil` to `stencil`. Can be applied to array of strings to change each string.

```html
{{ "Stencil"|lowercase }}
```

### default

If a variable not present in the context, use given default. Otherwise, use the value of the variable. For example:

```html
Hello {{ name|default:"World" }}
```

### join

Join an array of items.

```html
{{ value|join:", " }}
```

> The value MUST be an array. Default argument value is empty string.

### split

Split string into substrings by separator.

```html
{{ value|split:", " }}
```

> The value MUST be a String. Default argument value is a single-space string.

### indent

Indents lines of rendered value or block.

```html
{{ value|indent:2," ",true }}
```

Filter accepts several arguments:

- indentation width: number of indentation characters to indent lines with. Default is `4`.
- indentation character: character to be used for indentation. Default is a space.
- indent first line: whether first line of output should be indented or not. Default is `false`.

### filter

Applies the filter with the name provided as an argument to the current expression.

```html
{{ string|filter:myfilter }}
```

This expression will resolve the `myfilter` variable, find a filter named the same as resolved value, and will apply it to the `string` variable. I.e. if `myfilter` variable resolves to string `uppercase` this expression will apply file `uppercase` to `string` variable.

<!-- Copyright (c) 2022, Kyle Fuller
All rights reserved.

Copyright 2024 MFB Technologies, Inc.

This source code is licensed under the BSD-2-Clause License found in the
LICENSE file in the root directory of this source tree. -->
