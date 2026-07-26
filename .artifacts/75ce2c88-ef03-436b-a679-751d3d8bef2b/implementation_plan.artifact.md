# Implementation Plan - Center Alignment Fix for Border Selection Cards

Fix the layout of the "Change Border" screen to ensure all avatars and labels are perfectly centered within their cards.

## User Review Required

> [!IMPORTANT]
> The alignment issues are caused by the interaction between `Stack` and `Column` inside the `GridView`. I will wrap the content in centering widgets and ensure the selection/lock icons are correctly positioned as overlays without affecting the center alignment of the primary content.

## Proposed Changes

### [UI Components]

#### [MODIFY] [border_selection_screen.dart](file:///C:/QuestArena/lib/ui/screens/border_selection_screen.dart)
- Wrap the main `Column` (Avatar + Text) in a `Center` widget within the `Stack`.
- Set `crossAxisAlignment: CrossAxisAlignment.center` and `mainAxisAlignment: MainAxisAlignment.center` for the `Column`.
- Ensure the `Stack` itself has `alignment: Alignment.center`.

#### [MODIFY] [bordered_avatar.dart](file:///C:/QuestArena/lib/ui/widgets/bordered_avatar.dart)
- Verify `Stack(alignment: Alignment.center, ...)` is present to keep the `SmartAvatar` centered inside the border image.

#### [MODIFY] [smart_avatar.dart](file:///C:/QuestArena/lib/ui/widgets/smart_avatar.dart)
- Ensure the `SizedBox` wrapping the `SmartAvatar` build output uses `Alignment.center`.

## Verification Plan

### Manual Verification
- Open the **Border Selection** screen.
- Verify that every avatar (with or without a border) is exactly in the center of its card.
- Verify that the text label ("Gold Border", "None", etc.) is centered horizontally below the avatar.
- Ensure the lock icon stays in the top-right corner without shifting the avatar.
