# Advanced Pagination

A powerful Flutter pagination package with built-in infinite scrolling, pull-to-refresh, search, filtering, cursor pagination, and fully customizable loading experiences.

### ✨ Features

* Infinite scrolling
* Pull-to-refresh
* Page-based pagination
* Cursor-based pagination
* Search support
* Filter support
* Retry on error
* GridView support
* Sliver support
* Custom loading widgets
* Built-in shimmer loaders
* Built-in skeleton loaders
* Footer loading customization
* Theme customization
* Duplicate request protection

---

## Demo

<video src="https://raw.githubusercontent.com/Fayis2021/pagination-advanced/main/example/docs/demo.mov" width="400" height="450" autoplay loop muted playsinline></video>
---

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  advanced_pagination: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

# Basic Usage

```dart
PaginatedListView<Product>(
  fetch: _fetchProducts,
  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

---

# 🎨 Loader Configuration

The package provides multiple built-in loading styles.

## Initial Loading Type

Control the full-page loader displayed during the first API request.

```dart
PaginatedListView<Product>(
  fetch: _fetchProducts,

  loadingType: PaginationLoadingType.circular,

  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

Available options:

```dart
PaginationLoadingType.circular
PaginationLoadingType.linear
PaginationLoadingType.shimmer
PaginationLoadingType.skeleton
PaginationLoadingType.fadein
PaginationLoadingType.custom
```

| Loading Type | Description                       |
| ------------ | --------------------------------- |
| circular     | Circular progress indicator       |
| linear       | Linear progress indicator         |
| shimmer      | Shimmer placeholder rows          |
| skeleton     | Skeleton card placeholders        |
| fadein       | Fade animation while items appear |
| custom       | Developer supplied loader         |

---

## Custom Full-Page Loader

Provide your own loading experience.

```dart
PaginatedListView<Product>(
  fetch: _fetchProducts,

  shimmerBuilder: (context) {
    return PaginationShimmerEffect(
      child: Column(
        children: List.generate(
          6,
          (_) => MyCustomSkeletonRow(),
        ),
      ),
    );
  },

  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

> When `shimmerBuilder` is supplied, `loadingType` is ignored.

---

## Shimmer Colors

Customize shimmer appearance.

```dart
PaginatedListView<Product>(
  fetch: _fetchProducts,

  loadingType: PaginationLoadingType.shimmer,

  shimmerBaseColor: Colors.grey.shade300,
  shimmerHighlightColor: Colors.grey.shade100,

  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

Or use a theme:

```dart
PaginatedListView<Product>(
  fetch: _fetchProducts,

  loadingType: PaginationLoadingType.shimmer,

  theme: PaginationTheme(
    shimmerBaseColor: Colors.blueGrey.shade200,
    shimmerHighlightColor: Colors.blueGrey.shade50,
  ),

  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

---

## Footer Pagination Loader

Customize the widget displayed while loading additional pages.

```dart
PaginatedListView<Product>(
  fetch: _fetchProducts,

  loadingMoreBuilder: (context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text('Loading more...'),
          ],
        ),
      ),
    );
  },

  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

---

# 🔄 Pull To Refresh

```dart
PaginatedListView<Product>(
  enableRefresh: true,
  fetch: _fetchProducts,
  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

---

# 🔍 Search Support

```dart
paginationController.search("iphone");
```

Automatically resets pagination and loads fresh data.

---

# 🎯 Filter Support

```dart
paginationController.applyFilters({
  "category": "electronics",
  "brand": "apple",
});
```

---

# 📄 Cursor Pagination

Supports APIs that return cursors instead of page numbers.

```json
{
  "data": [],
  "nextCursor": "abc123"
}
```

Usage:

```dart
PaginatedListView<Product>(
  paginationType: PaginationType.cursor,
  fetchCursorPage: (cursor) async {
    return api.getProducts(cursor);
  },
)
```

---

# 🧱 GridView Support

```dart
PaginatedGridView<Product>(
  crossAxisCount: 2,
  fetch: _fetchProducts,
  itemBuilder: (context, product) {
    return ProductCard(product);
  },
)
```

---

# 🏗️ Sliver Support

```dart
CustomScrollView(
  slivers: [
    PaginatedSliverList<Product>(
      fetch: _fetchProducts,
      itemBuilder: (context, product) {
        return ProductCard(product);
      },
    ),
  ],
)
```

---

# 🛠️ Contributing

Contributions, issues, and feature requests are welcome.

Feel free to open an issue or submit a pull request.

---
### 📄 License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025 Muhammed Fayis

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
```

# 👤 Maintainer

**Muhammed Fayis**

GitHub: https://github.com/Fayis2021

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Fayis2021">
        <img src="https://avatars.githubusercontent.com/u/59821122?v=4" width="80px;" alt="Muhammed Fayis"/>
        <br />
        <sub><b>Muhammed Fayis</b></sub>
      </a>
      <br />
      📦 Package Author
    </td>
  </tr>
</table>
