perspective-collective
======================
The code is ugly and sloppy. But it works. Uses a custom collection view layout as well as the new physics engine.

Problems with it:

Disappearing items. The old problem of items being removed from view before they should be. Probably an issue with the translate transform making something visible when the collection view considers its frame to be out of view.
They also pop back in and out, and sometimes the transform screws up and shows it all giant.

I'd like the perspective to change more as items scroll, as safari does. Currently I'm half assing it by making the items move independently of one another while scrolling. Ideally it would be like a Rolodex, with the items in back bunching closer together and dropping down just a bit before going off screen, and the items at the very front would have less of a skew.
I'd like more items in view at a time--5 probably.
Most importantly, scrolling should continue to track the item underneath the finger. Currently it does not.
I'd also prefer the items to fill the screen better--currently they shrink down too much in the back, and get clipped in the front.
