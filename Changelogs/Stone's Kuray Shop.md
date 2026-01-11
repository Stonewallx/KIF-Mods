Stone's Kuray Shop - Changelog
# Version 1.1.0 (January 9, 2026)
---------------------------
[NEW]
- Added Auto-Update support via Mod Settings Registration.
- Added debug logging with error handling for all major operations
- Added initialization logging on mod load with version number
- Added PokemonMartAdapter override for proper custom price handling in Kuray Shop

[CHANGED]
- Moved Streamer's Dream item pricing out of base PRICES since it's handled in the Streamer's Dream section.
- Updated all debug logs to use consistent "StonesKurayShop:" prefix
- Updated version format to handle new registration.

[FIXED]
- Improved error handling for price calculations and display stock building
- Enhanced price lookup system to properly apply custom prices only in Kuray Shop context

# Version 1.0.0
---------------------------
[NEW]
- Initial release of Stone's Kuray Shop
- Custom shop with configurable items and prices
- Support for Streamer's Dream feature pricing
- Support for Kuray Eggs dynamic pricing
- Custom shop header display with color customization
