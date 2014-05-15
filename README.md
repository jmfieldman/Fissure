Fissure
=======

<a href="https://itunes.apple.com/us/app/fissure/id876534116">App Store Link</a>

<a href="http://fieldman.org/fissure">Website</a>

Apple constantly releases new frameworks, and the only way to keep up is to use them. I’ve read a lot of about Sprite Kit, and wanted to make something with it. I decided to recreate <a href="http://fieldman.org/light-jockey">Light Jockey</a>.

Sprite Kit is, generally, a pretty great offering. It encapsulates 2D object interaction and display really well, and the physics engine is capable and fast. The trade off is that you lose the ability add custom OpenGL effects to your game. So I got to move the particle engine to Sprite Kit, but I lost the ability to create particle effects that evolve over several frames. This basically nixes the particle glow trail.

So I worked within the capabilities of Sprite Kit and made the theme more “clean”. It’s basically the same game, but different graphics.

Making levels was still a pain in the butt. For each new level I would put a spawn point in a random location, add a random mix of controls/obstacles, and see what neat patterns I could make. I put targets in the path of that pattern and saved the level. I could probably had worked more on this, but I had already finished the engine (which was the main goal) and didn’t really want to spend time on this tedious part of the game.

Unless otherwise specified, all code is this repository is distributed under the MIT License (see LICENSE.md).