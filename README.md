JochensAlchemyProfits is a Turtle WoW / Vanilla 1.12 addon for Alchemists that helps track recipe profitability, scan Auction House prices, plan production, buy materials, craft efficiently and manage posted auctions.

The addon reads your learned Alchemy recipes and compares the current crafting cost with the cheapest available Auction House price. Reagent and potion prices are stored persistently and are only replaced by newer scans, so your data remains available between sessions. A 14-day price history helps put current prices into context.

The Recipes page shows crafting cost, lowest market price, expected profit and the last scan time for every learned recipe. You can scan selected recipes, favorites or all recipes, and optionally scan only finished potion prices.

The Materials page gives a dedicated overview of reagent prices, historical values and which recipes use each material. The Missing Recipes page helps track recipes you have not learned yet and can scan the Auction House for them.

The Production system is designed for larger crafting sessions. You can create reusable templates, choose a separate target amount for every potion, elixir or flask, calculate the total material requirements and scan the Auction House for the actual cost of buying the required stacks. If you need 50 materials but the cheapest auctions are sold in stacks of 20, JAP includes the full cost of buying 60 instead of pretending you can buy exactly 50.

Buy All Materials uses the cheapest suitable auctions while performing a fresh safety check before every purchase. Price increases above the configured safety margin are skipped. Previously scanned Production data can be reused for faster buying without removing the final price verification.

Craft All builds a production queue and tracks completed items, remaining quantities and missing materials. Because of Vanilla restrictions, crafting still requires player interaction when moving between recipe types, but JAP prepares the queue and guides the process with Craft Next.

Post All can automatically prepare Auction House listings using your configured stack size and duration. JAP normally undercuts the relevant market price by only 1 copper instead of unnecessarily lowering the market. A price-protection system also attempts to ignore obvious dumping outliers rather than blindly matching an extremely cheap listing.

The My Auctions page reads the auctions your character actually has posted and checks whether each potion, elixir or flask is still competitive. Listings are marked as CHEAPEST, TIED or UNDERCUT, with warnings when another seller becomes cheaper. You can select one or multiple product types and cancel their auctions, or cancel all currently undercut products at once. Cancelled auctions return through the normal Auction House mailbox.

JAP also includes persistent favorites, production templates, completion sounds, scan timestamps, live progress information and safeguards against temporary Turtle WoW API read errors corrupting stored recipe data.
