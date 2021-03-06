# MONOPOLY 

VERSION 0.02.80 BETA


FOR THE COMMODORE 64

BY DANIEL ENGLAND FOR ECCLESTIAL SOLUTIONS


(C) 2018 DANIEL ENGLAND
ALL RIGHTS RESERVED


MONOPOLY IS THE PROPERTY OF HASBRO INC.

(C) 1935, 2016 HASBRO



You probably need to own a copy of the official board game to even be reading
this.  *\*ugh\**


## TODO


* Change "all" dirty to be just board dirty and req. individual flags.


* rulesSuggestDeedValue should tap values based on group significance.
* AutoTradeApprove could tally "half points" for prime targets, getting almost and
  all of a group and require that they be accounted for in other deeds or money 
  (convert extra points too?).

* Optimise trade calculations -- too large!  24bit math!


* Should be able to do release state after above and all testing items passed.



* Player sprites on overview dialog?  Would look pretty.  IRQ is a mess.
* Mode chain integrity checks?  
* Is checking must pay after normal (non-elimination) action processing required 
  now?
* Put code into separate files as indicated.
* Is rent3 SFX still a little lame?  Does it matter?  Are the sounds okay on 
  Android (where the emulation is terrible)?
* Better (2 channel) sound for tax?
* Properly divide game and rule routines.  Hmm...
* CPU player personalities?  Not enough memory unless I do something radical in
  optimisation?
* Fix ZPage variable use, IRQ.
* Fix IRQ handler -- its gotten hacked to death.
* Game save/load?  Difficult now that the Kernal program and data space is used.
  May not have enough memory.
* Optimise, optimise, optimise eg. use BIT, self modifying code??
  Need cartridge/ROM support?  Already modify many data items.


## Optimisation Targets:

* The board displaying is not that great (fix all that INC varH).
* The trdsel0 dialog currently uses some 3KB of memory on top of the overview 
  dialog's nearly 1.5KB.  This is massive.  It should be optimised somehow.
* Zero page utilisation (IRQ!)
* I have accidentally used BPL (BMI?) for unsigned values.  This should be fixed to 
  use BCS/BCC where appropriate (I think I got them all?).


## For Testing (Needs Confirmation):

* Trade approval phase selection repay toggling works?
* Used GO Free cards prevented from appearing in deck until after shuffle (and while 
  owned by a player)?
* Trade correctly calculates remaining cash and enforces positive?
* Must pay works after trade?  Is it required now?
* Must pay works after elimination?
* Elimination works from must pay?
* Multiple eliminations in one turn works?
* Check not overflowing action cache???  Debug?  256 actions should be enough??
  What about CPU from trade from auction from elimination?  Still have same maximum
  number of deeds...
* Correct managing improvement behaviour (house/hotel count can't go negative and
  not be corrected by CPU?)
* Do not overflow heap??  Only 512 bytes in current allocation.  Should gather 
  statistics in order to check actual maximum requirements.  Should be fine, fine, 
  fine (was only 256 bytes and probably wouldn't overflow).


## Change History 

### Since Version 0.02.80B

* 08FEB2019
	* Don't use confirmation for CPU player on menuPageTrade1 confirm.
	* Use string references in dialogDlgNull0.

* 07FEB2019
	* Bail is now charged to the Bank Taxes account.
	* After starting a new game with keys only input, the menu options no longer
	  flash.
	* Change delay with auto group construction again.
	* No longer go into Must Pay when a player is in debt and the game is quit.

* 06FEB2019
	* Change delay with auto group construction.
	* Fix other than keyboard input error for menuPageSetupA.
	* Exomizer utilised.
	* Language select loader.

### Since Version 0.02.75B

* 06FEB2019
	* Management construct can auto group construct when constructing on 
	  highest improved deed.
	* Confirm menu from trade approval confirm.
	* Make menuPageQuit1 generic as menuPageConf0.
	* Fix bug calling menuPageQuit0 in menuPagePlay0StdKeys.
	* Fix bugs testing keys in menuPageQuit0Keys, menuPageQuit1Keys, 
	  menuPageQuit2Keys.

* 05FEB2019
	* Add house rule for starting with more than no deeds.  Expensive!
	* Make dialog elimin0 more informative about the elimination.
	* Fix Free Parking CCCCard detection logic.
	* Fix Free Parking CCCCard transactions to use Bank Taxes account.
	* Change Free Parking to none, taxes or taxes and CCCCards.
	* Add strings for free parking to be made none, taxes or taxes and CCCCards.
	* Fix bug in CCCCard AdvanceTo.
	* Fix potential bug in gameContinueAfterPost.
	* Add Land On Go Doubles Salary house rule toggling to setup6 menu.
	* Add Land On Go Doubles Salary house rule.

### Since Version 0.02.74B
	
* 04FEB2019
	* More "jail" spelling fixes.
	* CCCCard for "Boardwalk" spelling fix in English (USA).
	* Prompt for "Gone to Jail" in English (USA) not reversed.
	* Change language name from "English (American)" to "English (USA)".
	* Correct spelling of "Boardwalk" in English (American).
	* Fix menuPageAuctn0 to use string references.
* 03FEB2019
	* Fix regression in rulesNextImprv, rulesPriorImprv using rulesDoCollateImprv.
	* Correct spelling of "favour" in English (American).
	* Translate into English (American) with American place names.
	* String reference loading in boot strap initialisation.
	* Language select in boot strap initialisation.
	* Use string references in dialogDlgCCCCard0.
	* Use string references in prmptShuffle, prmptThinking.
	* Use player name references in menuPageSetup4, menuPagePlyrSel0,
	  dialogDlgWaitFor0, dialogDlgStart0, dialogDlgTrade7, dialogDlgElimin0, 
	  dialogDlgGameOver0, dialogDlgPStats0.
	* Add player name references.
	* Use string references in dialogDlgSqrInfo0, dialogDlgPStats0.
	* Use string references in menuPageSetup4.
	* Change menuPageSetup6 to use pointcodes for bullets.
	* Add pointcode for bullet.
	* Change prmptDisplay to use string references.
	* Change screenFillTextM to use string references.
	* Implement strrefs.

### Since Version 0.02.69B

* 03FEB2019
	* Prepare for string translations.
	* Game start music now triggered in game start dialog.
	* Fix modify of player name in some strings.  All high strings now constant.
	* Rename some string declarations for uniformness.

### Since Version 0.02.68B

* 09AUG2018
	* Fix non-obvious bug in NumConvPRTINT (immediate mode!)
* 04AUG2018
	* Code tidy
* 01AUG2018
	* Fix gamePopState handling of selection.
	* Keep/restore current selection with game state stack push/pop.
	* Recolour stats with dialog rebuilds after they are displayed.
	* Fix colouring trdsel0 frame.
	* Call menuElimin0RemWlthRecalc _after_ rulesInitTradeData!
* 31JUL2018
	* I suspect that AutoRecover in AutoAuction is messing with bid - 
	  work-around?
	* Cleanup all the game[Dec|Inc]Money<N> routines.
	* Call gamePlayerChanged in gameInitTrdIntrpt!
	* Remove unrequired stats dirty flag setting.
	* Make stats dirty in gamePlayerChanged.
* 29JUL2018
	* Increase "Victor's" delay time after improving.
	* Handle nothing to trade/auction when processing elimination.
	* Return improvements when processing elimination.
* 28JUL2018
	* Fix rulesNextImprv to check validity of improvement correctly.
	* Fix bug in rulesDoXferDeed incorrectly handling equity when the
	  deed is mortgaged.
	* Add equity debugging.
	* Correct problem in rulesFindHighestImprove testing other players.
	* "Victor" should now commit equity when appropriate in auctions.
	* Refactor rulesAutoBuy to allow reuse of wanted logic.


### Since Version 0.02.56B

* 27JUL2018
	* Bump version.
	* Begin rework of IRQ handler.
	* Add overview and statistics to elimin0 menu as below.
	* Add overview and statistics to trade0 and trade1 menus (via other page,
	  putting manage on the next page also).
	* Enable statistics for must pay menu (already had the others).
	* Change trade6 menu naming to jump1.
	* Set stats dirty when get key on setup0 menu.
	* Fix elimination processing incorrect player regression.
	* Reduce the priority of the utility group (so that houses on the others
	  aren't sold before mortgaging them).
	* Make "Victor" want to spend more in eliminations.
* 26JUL2018
	* Add dice debugging to store statistics about the dice rolled.
	* "Victor" should be "pressured" into improving when behind other players.
	* Fix trade player update regression.
	* Keys queue debugging and don't allow inject if buffer full.
	* Change "DEBUG_KEYS" define to "DEBUG_EXTRAS".
* 25JUL2018
	* Fix action context end issue causing an overflow of the action queue.
	* Remove all extraneous loading of active player pointers saving almost 1KB!
	* Convert all use of active player fetching/stashing to specific ZP.
	* Allocate specific zero page locations for active player pointer and 
	  update when changed.
	* Fix copy-paste bugs enabling/disabling trade buttons.
	* Change dialog delay in demo version.
	* Clear prompts when leaving setup1 menu.
	* Fix selection and not board update regression.
	* Focus on selected deed/square when going into management and restored
	  deed/square when leaving.
	* Restore auction prompt when return from management etc.
	* Attempt to prevent selection changes while processing actions when coming
	  from an auction (again).
	* Restore focus on auctioned deed/square when next in auction.
* 24JUL2018
	* Fix demo version page boundary indirect jump by moving menuActivePage0.
* 23JUL2018
	* Select square when must buy for humans to look cool too.
	* No longer use parameters passed in gameDeselect.
	* Don't clear prmpt1 (second) on roll, instead on move to square.
	* Fix demo version issues with dialogs.
	* Change the way dialogs are updated and displayed.
	* "Victor" now improves after trade group success.
	* Change use of game dirty flag from hard-coded values to defined consts.
	* Reduce flicker for dialogs/generally and prep for dirty flags changes.
	* More CPU debugging.
	* Change interpretation of game dirty flag $04 (not only select).
	* Dirty flag updating in gameSelect and gameDeselect.
	* Try to reduce the amount of flicker by using the dirty flags better after
	  rulesFocusOnActive.
	* Fix horrendous regression in boardGenAllH.  Thank you Git.
	* Add more extensive debugging for processing actions.
* 22JUL2018
	* Always call gameUpdateMenu from CCCCard procs.  This should fix CPU
	  player jam coming out of gaol onto a CCCCard.
	* I am enabling the heap and action useage debugging in builds for now.
	* Extend board display use of heap to more than 256 bytes (to be sure).
	* Clear rolls from inactive players on setup4 menu.
	* Put repay and fee sfx on voice 1.
	* Fix colour wrong for acquired prompt.
	* SFX for trade declined.
	* cpuHaveMenuUpdate deprecated, clear up setup cpuEngageBehaviour.
	* Clean up setting dirty flag after menuSetMenu and in setup.
	* menuSetMenu always updates dirty flag when changing display.
	* Add sfx for next player's turn.
	* Don't always need to call gamePlayersDirty after rulesFocusOnActive.
	* Try to prevent CPU from changing focus and selection in auctions.
	* Tidy mode checking in mainHandleUpdates.
	* Player positions for square 29 not correct.  Move for 30 (left) and 20 
	  (right) also.
	* Don't delay before roll again with doubles in AutoPlay.
	* Demo play version compile time option.
* 21JUL2018
	* Prompt for deed acquisition in trade.
	* Rework Overvw0 dialog drawing players, improvements and mortgages to reuse
	  data from TrdSel0 dialog saving some 670 bytes. 
	* rulesDoTradeMakeWanted applies rejection cooldown to value escalations.
	* AutoTradeInitiate applies a longer and longer base time to trade on 
	  rejection until approval (capped).
	* Don't show money buttons in trade approval on trdsel0.
	* rulesDoTradeMakeOffer includes mortgage flags in trade details.
	* AutoRecover shouldn't stop between selling houses and mortgaging any
	  longer.
	* Add SFX for trade initiation.
	* Change the priority of the sfx.
	* Also don't restart an already playing sfx.
	* Hack sound driver to not override non silence patterns with sfx
	  (except for voice 1).  This gives more stable sound I feel.
	* Do not include stations and utilities in rulesFindUnimprovedGroup.
	* Tweak other delay times.
	* Tweak action processing initiation delay and add delay after AutoBuy buy.
	* Add nice delay time control feature to DELY action processing.
	* Do not roll the dice and buzz when not in normal or action process modes 
	  in gameRollDice (as a precaution).  Also buzz for the other failures 
	  there.  This is mostly to give feedback for/control the CPU.  It still 
	  wouldn't be pretty...
	* Fix bug preventing address from being displayed on null0 dialog.
	* Fix bug in rulesGetGroupOwnInfo preventing correct flags returned.
	* Implement rulesAutoTradeInitiate and utilise by CPU.
* 20JUL2018
	* Use named contants instead of hard-coded game modes.
	* Use gamePushState/gamePopState for mode backup/restore on trdsel dialog.
	* Debug checking for game state stack, action context, action cache and
	  display heap.
	* Fix issue redisplaying state/player after trade decline.
	* Swap positions of players and improvements on overview.  No 
	  longer colour imprvs.


### Since Version 0.02.39A

* 20JUL2018
	* Bump version.  Moving to BETA status.
	* Fix GOFree trading bugs.
	* Fix trade regression (not transferring wanted).
	* Move trade data to high memory (into reserved area).
	* Fix square deselect/select issue?
	* Fix trade wanted repay/fees bugs/regression.
	* Fix AutoPay regression.
	* Correct elimination calculation of remaining money.
	* CPU faults if no actions to be taken.
	* Revert change: focus on player when perform next in auction (don't do it).
	* Fix elimination to bank bugs.
	* Fix cpuPerformMustPay.
	* Use UI::cLstAct instead of UI::cActns for compare of new actions.
	* Implement start marking/cancelling/ACT_ENDP for all action process contexts.
	* Make action cache multi-contextual (allow stacking of action processing).
	  This is primarily to allow the CPU to function in elimination auctions.
* 19JUL2018
	* Fix bug colouring hotel count in prmptUpdate.
	* No longer require prmptDisplay in CCCCard shuffles.
	* At least 1 per "tap" in rulesDoTapValue.  I think these changes may be
	  required to work-around another issue in AutoAuction but are also logical
	  enough.
	* At least 1 per "nudge" in rulesDoNudgeValue.
* 18JUL2018
	* Add start of debug checking of heap use by overvw/trdsel dialogs.
	* Fix heap indexing in overvw dialog to allow for larger heap use 
	  (required at peak utilisation).
	* Rework prompts clearing and how roll is redisplayed.
	* Eeii! Another missing '$' on bid.  Should have drawn.
	* Fix rulesAutoAuction for now.
	* Correct rulesSuggestBaseReserve.
	* Focus on player when perform next in auction.
	* Don't redraw whole menu for bid amount changes on auctn0 menu.
	* Further issues with prompts, no longer kill zero page common.
	* Modify early init to load screen data.
	* Modify early init to not rely on screen module.
	* Modify strings/screen/rules files to allow for collecting free memory.
	* Move screen data to end of strings data.
* 17JUL2018
	* Kill unrequired sprPointer data from discard.
	* Fix setup7 input issues.
	* Different prompt for construct.
	* Fix bought, tax et al prompt strings (missing $).
	* Fix rolled prompt data regression.
	* Optimise prompts code and move data to strings, saving almost 0.5KB.
	* Thinking prompt when cpu engaged.
	* Change order of buttons on setup6 house rules menu.
	* Change order of buttons on set funds setup menu (normal, low, high).
	* Prompt for trade initiated.
	* Prompts for actions taken on trade approve menu (approved/declined).
	* Implement AutoTradeApprove and utilise by CPU.
	* rulesSuggestDeedValue takes into account mortgaged state and properly
	  gets market value.
* 16JUL2018
	* Consolidate all the backup/retrievals of game mode + player into a 
	  single main state stack.
	* Put AutoPay button on play2 menu (already has key input handling).
	* Add strOptn9Play0 and strDescElimin0 strings.
	* Colour gofree items on trdsel0 dialog to indicate availability.
	* Fix user input handling issues (at start and when DEBUG_CPU not enabled).
	* Move keys globals out of globals area.
	* Move IRQ globals into globals area ($0200-$03FF).
	* Code clean-up.
* 15JUL2018
	* Indicate (border colour red) when an unknown source of IRQs is
	  encountered (this will cause serious issues).
	* Move VIC-II IRQ acknowledgement to start of IRQ routine to ensure that it
	  is always done.
	  
	  
### Since Version 0.02.19A

* 15JUL2018
	* Bump version.
	* Implement CPU player menu setup9.
	* Don't allow mortgaging/unmortgaging of deeds in a trade when trading.
	* Don't allow construct improvements from manage menu when coming from trade.
	* Add manage option to trade0, trade1 and elimin0 menus.  Recalculate
	  remaining wealth and cash when utilised.  These last few changes 
	  required nearly 1.5KB so were very expensive.
	* Do not allow trade/elimination xfer if remaining money is negative.
	* Now include remaining money on trdsel dialog and update with changes made.
	* Return to correct player after elmination and must pay.
	* Change text "cash" on trdsel0 dialog to "money".
* 14JUL2018
	* Normalise VIC-II settings in bootstrap.
	* Add strings for CPU players menu (setup9).
	* Change texts on trade6 menu for action updating.
	* Prompt for actions taken on auction menu.
	* Fix rulesDoCommitMrtg to not step through all squares (just squares in
	  group), to also check improvements and correctly flag mortgage.
	* Don't improve in rulesDoConstructAtLevel when have insufficient funds
	  already.
	* Change setting/usetting of carry in gameAmountIsLess (et al) to match 
	  CPU unsigned behaviour for less than (carry clear not carry set).
	* Bump version.
	* Implement AutoAuction.
	* Fix GOFree card trade?
* 13JUL2018	
	* CPU mustn't roll and then post in AutoGaol.
	* Add debugging data (player and address) for CPU fault to null0 dialog.
	* Save the last selected button and attempt to restore it as the current
	  selection when redrawing the same menu.  This should work when going 
	  between dialog and menu but mostly this will involve a menu change, 
	  anyway.
	* Add actual GOFree card exchange to trade.
	* Fixed menu looping when no deeds in trade.
	* Don't assume mouse when receiving space in setup7 keys.  Assume invalid 
	  input unless flag set for peripheral device and check peripherals properly.
	* Implement MouseUsed flag for determining source of generic input.
	* Fix bug in uiPerformBuy causing price to not be paid.
	* Some other delays.  It is more versatile this way...
	* Add delay to next out of gaol and after AutoImprove, AutoRepay (not both)
	  and AutoRecover.  I find this funny because I optimised the delay away
	  and then put it back again for some/many cases.
	* Fix CPU not engaging on menu changes when joystick input not enabled and
	  strange artefacts updating button selection (also get hot flashing for
	  mouse now?).
	* AutoImprove from gaol.
	* Calculate suggested base reserve correctly.
* 12JUL2018
	* Fix key code for repay button on trdsel0 dialog.
	* Remove special key (control, shift, CBM) handling from key scan.
	* Revert change to lead time on processing actions.
	* Fix CPU making invalid selection for Setup1 menu.
	* Fix bug in init code (I shouldn't need that code, anyway).
	* Fix a problem with hot button flashing.
	* Move more init code into discardable area.
	* Move/add some init code into bootstrap.
	* Move some discardable data/code to after heap ptr to save memory.  Saved
	  some 300 bytes for program.
	* Code tidy.
	* Move heap ptr and top of program data expectation.
	* Remove extra sprite data definitions.  In the end, these last changes
	  should have saved around 300 to 400 bytes.
	* Move all sprite data to $0800+.
	* Move ui, game, plr, sqr and keys globals to $0200+.  This should have
	  saved about 500 bytes but it doesn't because of the above.
	* Refactor GAME::tPrmT0/1+tPrmC0/1 into own space.
	* Refactor key scan routine to use variables instead of addresses.
	* Fix AutoGaol bug.
* 11JUL2018
	* Fix AutoRepay, AutoEliminate bugs.
	* Move Action cache into high memory saving another 1KB for program area.
	* Fixed elimination bugs.
	* Correct PlyrSel0 menu display issues.
	* Correct TrdSel0 dialog button and display issues.
	* Add the remaining equity in an elimination to the correct player.
	* The method of blanking the menu for a cpu player (to prevent flickering)
	  was invalid.  Fixed.
	* Rename "AutoSell" to "AutoPay".  Much better.
	* Implement AutoEliminate.
	* Implement AutoRepay.
* 10JUL2018
	* Move rules constant data into high memory (and load at start).
	* Implement AutoConstruct for AutoImprove (need AutoRepay).
	* Fix spurious auctn0 menu redraws bug that is now causing crashes.
	* Optimise some routines.
	* CPU performs behaviour for setup (somewhat naughty).
	* CPU behaviour mechanisim now implemented.  
	* Implement key injection queue and processing.
	* Debug action processing.
* 09JUL2018
	* Beginning of cpu behaviours.  Remove features from debugging.
	* Beginnings of AutoPlay.  Only in debugging.
	* AutoGaol.  Only in debugging.
	* Add AutoBuy available from debugging.
* 08JUL2018
	* Buzz when fail get out free.
	* Fix order of buttons on trdsel0 dialog.
	* Autosell feature.  Still not properly incorporated into menus.
	* Load strings resource.  This is still very slow. *\*sigh\**
	* Rip out strings and put in separate files.  I have built a strings.prg
	  file out of the process but I can't get exomiser to work yet so the
	  process is unfinalised.
	* Unload Kernal and use the machine bare.
	* Replace Kernal scankey with my own copy. *\*ugh\**
* 07JUL2018
	* Rework trade stepping interrupt into a generic execute on the 
	  front-end feature, ui Actions.


### Since Version 0.01.99A

* 07JUL2018
	* Bump the version.  I have everything in from my initial requirements
	  (except for tidy up) and am now going beyond.
* 06JUL2018
	* Buzz when fail attempting to mortgage, construct or sell.
	* Change order of button on setup3 and setup5 menus to better 
	  reflect the usual selections and minimise movements.
	* Fix bug in menuDisplay affecting button selection.
	* Add game options, input config options to play menu.
	* Add another play menu (Play2) for statistics and quit.
	* Rework some setup menus (now use some tricks!).
	* Better order to setup menus, new labels.
	* Whoops, immediate mode in initMem.
	* Clear up "property" naming issues (streets/deeds/improvements).
	* Add menus and funtionality to initiate/confirm game quit.
	* Add player score to PStats dialog.
	* Calculate player score.
* 05JUL2018
	* Rework eliminations.  *\*Phew!\**  The extra layers of interface and
	  processing makes this an overall increase to the executable size
	  which I was hoping to keep smaller than it is.
	* Navigate single cell buttons (money) more intuitively with
	  joystick (this was a surprisingly large change).
* 04JUL2018
	* Disable bid (and don't perform) when have insufficient money.
	* Disable all trade buttons when have negative money.
	* Fix show "doubles" on play menu.
	* Fix buttons bug closing non default drawn dialogs.
	* Optimise player name handling (some).
	* All button types supported for hot tracking.
	* Fix keys for buttons on PlyrSel menu.
	* Update some CCCCard texts.
	* Input sensitivity control when input is joystick.
	* Inform when 3 doubles is reason for gaol (in menu desc).
	* Inform when have doubles on play menu (in desc).
	* Hot track blinking.
	* Note to self:  Got all below in with data space saved.
	* Basic button hot tracking (still need more types support).
	* Complex joystick movement and button selection/input translation.
	* Detect mouse or joystick click for input config selection.
	* Rework mouse selection.
	* Add basic joystick driver and button selection.
	* Fix menu only updates affecting whole screen?
	* Allow only unique colours for each player.
	* Added more button types and auto draw, remove redundant data 
	  (saved about 800B of data!).
* 03JUL2018
	* Disable debug keys by default.
	* Disable filter in tunes at end to get SFX on channel 0 working better.
	* Implement Free Parking Taxes House Rule.
	* Add House Rules setup menu (Setup6).
	* Add statistics and enable trade option on Gaol2 menu.
	* Add a second page to the auctions menus.
	* Do not allow trades if player is in debt.
	* Use menuPush for Player Selection menu instead of return hack.
	  Just to mention, I'm not sure that returning to the second page of
	  some menus is the desired behaviour.  I don't know how to change this.
	* Allow up to two menu pages to be stored in its stack (just in case).
* 02JUL2018
	* Tweak some strings.
	* Optimise trade data area size (only need data for tradeable deeds).
	* Fixed display of # utilites on Players Stats dialog.
	* Fixed display of # stations on Players Stats dialog.
	* Fixed display of # of GO Free cards on Players Stats dialog.


### End of Transcript
