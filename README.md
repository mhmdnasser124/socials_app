# Socials App

A Flutter social feed application built with Clean Architecture principles.

<div align="center">

[![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-success)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![State Management](https://img.shields.io/badge/State-BLoC-purple)](https://bloclibrary.dev)

</div>

---

## Video Demo

<div align="center">

[![Socials App Demo](https://img.youtube.com/vi/0tDo1Bhwj2U/maxresdefault.jpg)](https://youtube.com/shorts/0tDo1Bhwj2U)

**[Watch Demo Video](https://youtube.com/shorts/0tDo1Bhwj2U)**

</div>

---

## Screenshots

<div align="center">

<table>
<tr>
<td><img src="screenshots/splash_screen.png" width="180" alt="Splash Screen"></td>
<td><img src="screenshots/feed_screen.png" width="180" alt="Feed Screen"></td>
<td><img src="screenshots/post_creation.png" width="180" alt="Post Creation 1"></td>
<td><img src="screenshots/post_creation2.png" width="180" alt="Post Creation 2"></td>
<td><img src="screenshots/post_creation3.png" width="180" alt="Post Creation 3"></td>
</tr>
<tr>
<td align="center"><b>Splash</b></td>
<td align="center"><b>Feed</b></td>
<td align="center"><b>Post 1</b></td>
<td align="center"><b>Post 2</b></td>
<td align="center"><b>Post 3</b></td>
</tr>
<tr>
<td><img src="screenshots/comments.png" width="180" alt="Comments 1"></td>
<td><img src="screenshots/comments2.png" width="180" alt="Comments 2"></td>
<td><img src="screenshots/comments3.png" width="180" alt="Comments 3"></td>
<td></td>
<td></td>
</tr>
<tr>
<td align="center"><b>Comments 1</b></td>
<td align="center"><b>Comments 2</b></td>
<td align="center"><b>Comments 3</b></td>
<td></td>
<td></td>
</tr>
</table>

</div>

---

## Overview

Social feed platform where users can:

- Create posts with text and up to 2 images
- View community feed (Latest tab - approved posts only)
- View personal posts (My posts tab - all posts including pending/rejected)
- Like & comment on approved posts

---

## Architecture

This project follows **Clean Architecture** principles with clear separation between Presentation, Domain, and Data layers.

### Clean Architecture Diagram

<div align="center">

<table>
<tr>
<td><img src="https://i0.wp.com/resocoder.com/wp-content/uploads/2019/08/CleanArchitecture.jpg?w=772&ssl=1" width="350" alt="Clean Architecture"></td>
<td><img src="https://i0.wp.com/resocoder.com/wp-content/uploads/2019/08/Clean-Architecture-Flutter-Diagram.png?w=556&ssl=1" width="350" alt="Clean Architecture Flutter"></td>
</tr>
<tr>
<td align="center"><i>Source: <a href="https://resocoder.com">ResoCoder</a></i></td>
<td align="center"><i>Source: <a href="https://resocoder.com">ResoCoder</a></i></td>
</tr>
</table>

</div>

### Dependency Flow

```
Presentation → Domain → Data
```

---

## Project Structure

```
lib/
├── core/                    # Shared utilities
│   ├── config/             # Dependency injection
│   ├── services/           # Cache, networking
│   └── UI/                 # Theme, localization, widgets
└── features/
    └── socials/            # Social feed feature
        ├── data/          # Data layer
        ├── domain/         # Business logic
        └── presentation/   # UI layer
```

---

## Key Features

- Two-tab feed system (Latest / My posts)
- Post creation with media (up to 2 images)
- Post approval workflow (pending/approved/rejected states)
- Like & comment interactions
- Optimistic UI updates
- Infinite scroll pagination
- Responsive design with AppSize system
- Shimmer skeleton loading
- Localization (English & Arabic)

---

## Key Dependencies

- `flutter_bloc` - State management
- `auto_route` - Navigation
- `get_it` + `injectable` - Dependency injection
- `easy_localization` - Multi-language support
- `cached_network_image` - Image caching
- `shimmer` - Loading animations
- `dio` - HTTP client

---

## Task Checklist

| Requirement       | Location                             |
| ----------------- | ------------------------------------ |
| Two-tab feed      | `SocialsShellPage` + `FeedListView`  |
| Post creation     | `ComposerCard` + `CreatePostUseCase` |
| Approval states   | `PostCard` + `PostStatus` enum       |
| Like & Comment    | `FeedBloc` + `CommentsBloc`          |
| Pagination        | `FeedBloc.loadMore`                  |
| Responsive design | `AppSize` system                     |
| Skeleton loading  | `feed_list_view.dart`                |

---

## Development

### Adding Features

1. Create use case in `domain/usecases/`
2. Implement repository in `data/repositories/`
3. Add BLoC in `presentation/blocs/`
4. Build UI in `presentation/widgets/`

### Code Style

- Use `AppSize` for all dimensions
- No hardcoded values
- Function declarations only
- Minimal comments

---

<div align="center">

**Built with Flutter & Clean Architecture**

</div>
