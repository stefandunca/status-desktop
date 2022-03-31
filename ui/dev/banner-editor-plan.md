# Banner editor plan

## Requirements

Allow user to edit the community banner to match the requirements (size, aspect ratio ...)

Banner editor has most of the requirements common with Community logo and Profile logo editor

Requirements list

- Section in `CommunityEditSettingsPanel.qml`
  - Section text header
  - Image preview editor with add option (plus sign)
    - Support edit (pencil) if already set? 
  - Add will span a popup
- Popup spanned when adding or changing
  - Title
  - Image/banner editor
  - Action to apply changes
- Add new generic reusable control for image editing `StatusQ.BadgeImageEditor`
  - Show window effect
    - Full transparency in the `on zone` and half transparency black overlay in the off zone
  - Allow user to pan and zoom
    - Pan using mouse drag
    - Zoom using scroll and bottom slider
  - Respect limits: pan and zoom
  - Two mods: preview and edit
  - Have good defaults
    - Zoom?
      - [x] ~~Fill~~
      - [x] Fit
    - Pan: centered
  - Size limit
    - Show if the size is not respected
    - Have option to fix it
      - [x] Checkbox?
  - Have aspect ratio support 1:1, 16:9?
  - Supported shapes
    - Rectangular
    - Circle
    - Ellipses

## Implementation

Too big file use case

- Show warning and allow user to fix it
  - [x] Ways
    - Checkbox and disable button until fix checkbox is checked?
    - Set/Update button is "fix size and save/update"
    - No warning, just fix it in status-go
- Resize and optimize image
  - [x] Backend or qml workaround?
    - status-go

### StatusQ.BadgeImageEditor

QML control

- Use layering and `SourceMask` to get the window effect
    - Bad idea, going with Canvas overlay
- Mask as Rect
  - [x] Can it work for circle? How about Ellipses?
    - Can't do ellipses, went with Canvas 

Data Model

- Image source
  - Disk file path
- Rectangle of the inscribed ellipse
  - This will define the AR
    - [x] Conflict between the AR and position
      - Center when everything change ~~or keep left/top corner~~

## Checkpoints

- [x] 1. Basic editor (StatusQ.BadgeImageEditor) with QML model (store?)
  - [x] 1.1 QML component
  - [x] 1.2 QML integration tests
    - Sanity checks for all cases
    - Follows basic positioning
- [ ] 2. Integrate with the existing nim model `communities.nim` - `createCommunity` & `editCommunity` through -> chatCommunitySectionModule
- [ ] 3. Image resizing
  - [status-go support](https://github.com/status-im/status-go/blob/16311512cbf66c9eeaf03194707faa19c9390649/images/main.go#L36)
    - First look it seems it does trial and check while reducing jpg quality level [encode.go](https://github.com/status-im/status-go/blob/16311512cbf66c9eeaf03194707faa19c9390649/images/encode.go#L30)
      - [ ] Reducing resolution vs encoding quality for image size fit for Banner, Logo and Profile
    - Supports two dimensions for now [meta.go](https://github.com/status-im/status-go/blob/16311512cbf66c9eeaf03194707faa19c9390649/images/meta.go#L30)
- [x] ~~Controller and Data Model in middleware layer~~

## Info

`status-go` image manipulation: [src](https://github.com/status-im/status-go/tree/develop/images)
Research on profile photo: [status-go issue](https://github.com/status-im/status/issues/36)

- `identityImage` allows an entity to have images associated with their chat key
- designed to be expanded with other types of images to an identity
