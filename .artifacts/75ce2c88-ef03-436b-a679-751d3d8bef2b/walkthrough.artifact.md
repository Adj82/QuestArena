# Walkthrough - Alignment Fixes for Avatar and Border Cards

I have fixed the alignment issues across all customization screens to ensure that avatars, borders, and labels are perfectly centered within their respective cards.

## Changes Made

### 1. Border Selection Alignment
Refactored the card layout in the "Change Border" screen.
- Used `Positioned.fill` and `mainAxisAlignment: center` / `crossAxisAlignment: center` to ensure the avatar and text are exactly in the middle of the card.
- Optimized the overlay positioning (lock and checkmark) to prevent them from shifting the central content.
- [border_selection_screen.dart](file:///C:/QuestArena/lib/ui/screens/border_selection_screen.dart)

### 2. Bordered Avatar Consistency
Updated `BorderedAvatar` to guarantee centered rendering of the avatar within the border image.
- Enforced strict sizing with `SizedBox` and `Stack(alignment: Alignment.center)`.
- Adjusted the avatar-to-border scale for a more balanced visual fit.
- [bordered_avatar.dart](file:///C:/QuestArena/lib/ui/widgets/bordered_avatar.dart)

### 3. Global Card Alignment
Applied explicit horizontal centering (`crossAxisAlignment: center`) to similar grid components across the app to prevent future alignment drifts.
- Fixed `AvatarSelectionScreen` grid tiles.
- Fixed `AvatarCollectionScreen` grid tiles.
- [avatar_selection_screen.dart](file:///C:/QuestArena/lib/ui/screens/avatar_selection_screen.dart)
- [avatar_collection_screen.dart](file:///C:/QuestArena/lib/ui/screens/avatar_collection_screen.dart)

## Verification Results

> [!TIP]
> **Visual Balance**: All customization cards now exhibit perfect horizontal and vertical symmetry.
> **Overlay Stability**: Selection indicators and lock icons are now correctly pinned to the corners without affecting the center alignment of the avatars.
