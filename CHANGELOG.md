## [1.06] - 2026-06-11

### Added
- An option to select Pass Group when customizing a Pass. The Pass Group can be used to group (or separate) passes once added to Wallet.
- An option to select an expiration date when customizing a Pass.
- An option to select a location alert when customizing a Pass. A notification with the alert text will be shwon when near the selected location(s) for the pass.
- The ability to capture photos with the Camera when customizing various Pass images.

### Fixed
- Bug causing QR Code Encoding to not apply to saved Passes.
- Crash when using non UTF-8 characters in QR codes.
- Issue when cropping logo images where only rectangles with wide aspect ratios were allowed.
- Bug causing additional secondary/auxiliary fields to not appear at the previewed location when generated as a Wallet pass.

## [1.05] - 2026-06-05

### Added
- Russian language support

## [1.04] - 2026-05-17

### Fixed
- A bug that caused a crash when generating passes containing non-unique labels on text fields

## [1.03] - 2026-04-10

### Added
- Support for Wi-Fi and VCard QR Codes
- Support for thumbnail images
- Support for importing existing Wallet passes
    - Click the share button from a pass already saved to your Wallet, and PassKeepr will show up as a sharing option
- Confirmation before discarding unsaved changes to Passes
- The ability to pan, crop, resize, and adjust the aspect ratio of images before saving them

### Changed
- Improved backend responsiveness
- Improved accuracy of PassCard preview
- UI Improvements throughout

## [1.02] - 2025-10-26

### Added
- Support for Liquid Glass for devices running iOS 26
- Ability to save pass locally without signing it

### Changed
- Overhauled UI for cleaner navigation, saving, and editing of passes
- Improved drag/drop performance of passes on main screen

## [1.01] - 2025-01-28

### Added
- Support UPC-A barcodes

## [1.0] - 2025-01-25

### Added
- Support for the following barcodes:
    - QR Codes (incl. alt text support)
    - Code 128 (incl. alt text support)
    - PDF417 (incl. alt text support)
    - Code 39
    - Code 93
    - UPC-E
- Support for background images (EventPass only)
- Support for custom strip images
- Support for custom logo image via Photo, Emoji, or SF Symbol
- Support for Primary, Secondary, and Header fields
- Support for custom background, text, and label colors
- Support for duplicating, sharing, deleting, and rearranging of passes on the main pass view screen
- Support for editing of existing passes
- Support for communicating with a remote server for pass verification and signing
