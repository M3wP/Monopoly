# MONOPOLY 

VERSION 0.02.56 BETA


FOR THE COMMODORE 64

BY DANIEL ENGLAND FOR ECCLESTIAL SOLUTIONS


(C) 2018 DANIEL ENGLAND
ALL RIGHTS RESERVED


MONOPOLY IS THE PROPERTY OF HASBRO INC.

(C) 1935, 2016 HASBRO



You probably need to own a copy of the official board game to even be reading
this.  *\*ugh\**


## TODO

* CPU player still needs:  AutoTradeInitiate
* rulesSuggestDeedValue should tap values based on group significance.
* AutoAuction should commit equity like AutoBuy does and perhaps not bail so 
  early (push value upwards if its less than what they and other players currently 
  have -- calc minimum as well as max?).
* AutoTradeApprove could tally "half points" for prime targets and require that they
  be accounted for in other deeds or money (convert extra points too?).
* Is checking must pay after normal (non-elimination) action processing required now?
  
* Swap positions of players and improvements on overview.  No longer colour imprvs.

* Statistics/Overview from trade approval, must pay.  They should work now.
* Make dialog elimin0 more informative about the elimination (to player/bank)?
* Change trade6 menu naming to jump1 menu.
* Check is normal mode in gameRollDice.
* Could also do other mode chain integrity checks?  
* Don't overflow game state stack!  Debug?
* Check not overflowing action cache contexts.  Debug?
* Check not overflowing action cache???  Debug?
* Do not overflow heap??  Only 512 bytes in current allocation.  Should gather 
  statistics in order to check actual maximum requirements.  Should be okay.

* Allow players to input name?  Do I have enough memory for the feature??
* Could now instead of copy name on elimin and gameover dialogs, just refer.
* Optimise trade calculations -- too large!

* Player sprites on overview dialog?  Would look pretty.  IRQ is a mess.
* Get exomiser working.
* Allow construct from manage menu in trade if not doing so for group in trade?

* Should be able to do release state after above and all testing items passed.

* Change "all" dirty to be just board dirty and req. individual flags?
* Put code into separate files as indicated.
* Is rent3 SFX still a little lame?  Does it matter?  Are the sounds okay on 
  Android (where the emulation is terrible)?
* Properly divide game and rule routines.  Hmm...
* CPU player personalities?  Not enough memory unless I do something radical in
  optimisation?
* Fix ZPage variable use, in particular active player pointer and IRQ.
* Fix IRQ handler -- its gotten hacked to death.
* Game save/load?  Difficult now that the Kernal program and data space is used.
  May not have enough memory.
* Optimise, optimise, optimise eg. use BIT, self modifying code??
  Need cartridge/ROM support?  Already modify many data items.


## Optimisation Targets:

* The trdsel0 dialog currently uses some 3KB of memory on top of the overview 
  dialog's nearly 1.5KB.  This is massive.  It should be optimised somehow.
* Zero page utilisation (get rid of all those reloads for current player!  IRQ!)


## For Testing (Needs Confirmation):

* Used GO Free cards prevented from appearing in deck until after 
  shuffle (and while owned by a player).
* Trade correctly calculates remaining cash and enforces positive.
* Must pay works after trade?  Is it required now?
* Must pay works after elimination?
* Multiple eliminations in one turn works?
* In elimination auctions, auctioned square keeps selection.
* Does trading during auctions work?


## Change History 

### Since Version 0.02.56B



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