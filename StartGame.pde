// ===============================
//  RETRO MENU — SMALL FONT + LEFT ALIGN + SLOW JITTER
// ===============================

//PFont retroFont;

String[] menuItems = { "START", "CHANGE SKIN", "SETTING", "QUIT" };
String[] menuSetting = { "Audio", "Brightness", "Credits" };
String[] Audio = { "[]", "[]", "[]", "[]", "[]" };
int selected = 0;

int jitterCooldown = 0;   // untuk memperlambat jitter
float jitterX = 0;
float jitterY = 0;

boolean menu = true;
boolean first = false;
boolean setting = false;
boolean audio = false;
float volume = 0.3;

boolean brightness = false;
boolean credits = false;


void drawMenu() {
  if (menu) {
    background(20, 30, 50);
    fill(255);
  
    // Judul
    textAlign(CENTER);
    textSize(34);
    text("BRICK BREAKER", width/2, 120);
  
    // High Score
    textSize(16);
    text("High Score : " + highskor, width/2, 170);
  
    // Menu
    textSize(18);
    
    //key map
    keymapUpDown();
    
    for (int i = 0; i < menuItems.length; i++) {
  
      float x = 100;
      float y = 260 + i * 55;
  
      // pointer + jitter untuk yg dipilih
      if (i == selected) {
  
        // perlambat jitter (update setiap 10 frame)
        if (jitterCooldown <= 0) {
          jitterX = random(-1.2, 1.2);
          jitterY = random(-1.2, 1.2);
          jitterCooldown = 10;
        } else {
          jitterCooldown--;
        }
  
        textAlign(LEFT, CENTER);
        text(">", x - 30, y);  // pointer
  
        x += jitterX;
        y += jitterY;
      }
  
      // teks menu
      textAlign(LEFT, CENTER);
      text(menuItems[i], x, y);
    }
    velocity.x = 0;
    velocity.y = 0;
  }
}

void drawSetting() {
  if (setting) {
    background(20, 30, 50);
    fill(255);
  
    // Judul
    textAlign(CENTER);
    textSize(27);
    text("Pilih Jenis", width/2, 160);
  
    // Menu
    textSize(18);
    
    keymapUpDown();
    keymapEsc();
    
    for (int i = 0; i < menuSetting.length; i++) {
  
      float x = 100;
      float y = 240 + i * 55;
  
      // pointer + jitter untuk yg dipilih
      if (i == selected) {
  
        // perlambat jitter (update setiap 10 frame)
        if (jitterCooldown <= 0) {
          jitterX = random(-1.2, 1.2);
          jitterY = random(-1.2, 1.2);
          jitterCooldown = 10;
        } else {
          jitterCooldown--;
        }
  
        textAlign(LEFT, CENTER);
        text(">", x - 30, y);  // pointer
  
        x += jitterX;
        y += jitterY;
      }
  
      // teks menu
      textAlign(LEFT, CENTER);
      text(menuSetting[i], x, y);
    }
    velocity.x = 0;
    velocity.y = 0;
  }
  
    if (audio && !setting) {
    background(20, 30, 50);
    fill(255);
  
    // Judul
    textAlign(CENTER);
    textSize(27);
    text("Audio", width/2, 160);

    // Volume level display
    textSize(24);
    text("Volume: " + int(volume * 10), width/2, 220);
    
    keymapRightLeft();
    keymapEsc();

    // Single loop for the active skin type
    for (int i = 0; i < Audio.length; i++) {
      float x = 120 + i * 55;
      float y = 300;

      // pointer + jitter untuk yg dipilih
      if (i == selected) {
        
        // perlambat jitter (update setiap 10 frame)
        if (jitterCooldown <= 0) {
          jitterX = random(-1.2, 1.2);
          jitterY = random(-1.2, 1.2);
          jitterCooldown = 10;
        } else {
          jitterCooldown--;
  
        x += jitterX;
        y += jitterY;
        }
      }
      if (i == selected + 1) {
        textAlign(LEFT, CENTER);
        textSize(18);
      }
  
      // teks menu
      textAlign(LEFT, CENTER);
      text(Audio[i], x, y);
    }
    velocity.x = 0;
    velocity.y = 0;
  }
}

void keyPressed() {  
    if (menu) {
      sin.play();
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    if (keyCode == UP || key == 'W' || key == 'w') {
      sin.freq(350);
      selected--;
      if (selected < 0) selected = menuItems.length - 1;
    }
    else if (keyCode == DOWN || key == 'S' || key == 's') {
      sin.freq(350);
      selected++;
      if (selected >= menuItems.length) selected = 0;
    } 
    // ===========================
    //   SPACE untuk memilih
    // ===========================
    else if (keyCode == 32 && keySpace) {   // SPACE
      sin.freq(700);
    
      if (selected == 0) {
        println("START dipilih");
        menu = false;
        first = true;
        if (!paused || savedVelocity == null) {
          velocity.x = random(2, 4) * (random(1) > 0.5 ? 1 : -1);
          velocity.y = -random(6, 8);
        } else {
          velocity = savedVelocity.copy();
          paused = false;
        }
      }
      if (selected == 1) {
        println("CHANGE SKIN dipilih");
        menu = false;
        skin = true;
        selected = 0;
      }
      if (selected == 2) {
        println("SETTING dipilih");
        menu = false;
        setting = true;
        selected = 0;
      }
      if (selected == 3) {
        println("QUIT dipilih");
        exit();
      }
      keySpace = false;
    }
  }
  
    if (skin) {
      sin.play();
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    if (keyCode == UP || key == 'W' || key == 'w') {
      sin.freq(350);
      selected--;
      if (selected < 0) selected = menuSkin.length - 1;
    }
    else if (keyCode == DOWN || key == 'S' || key == 's') {
      sin.freq(350);
      selected++;
      if (selected >= menuSkin.length) selected = 0;
    } 
    // ===========================
    //   SPACE untuk memilih
    // ===========================
    else if (keyCode == 32 && keySpace) {   // SPACE
      sin.freq(700);
    
      if (selected == 0) {
        println("Ball dipilih");
        skin = false;
        ballSkin = true;
        selected = 0;
      }
      else if (selected == 1) {
        println("Paddle dipilih");
        skin = false;
        paddleSkin = true;
        selected = 0;
      }
      else if (selected == 2) {
        println("Brick dipilih");
        skin = false;
        brickSkin = true;
        selected = 0;
      }
      keySpace = false;
    }
  }
  
    if (ballSkin || paddleSkin || brickSkin) {
      sin.play();
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    if (keyCode == UP || key == 'W' || key == 'w') {
      sin.freq(350);
      selected--;
      if (ballSkin & selected < 0) selected = Ballskins.length - 1;
      if (paddleSkin & selected < 0) selected = Paddleskins.length - 1;
      if (brickSkin & selected < 0) selected = Brickskins.length - 1;
    }
    else if (keyCode == DOWN || key == 'S' || key == 's') {
      sin.freq(350);
      selected++;
      if (ballSkin & selected >= Ballskins.length) selected = 0;
      if (paddleSkin & selected >= Paddleskins.length) selected = 0;
      if (brickSkin & selected >= Brickskins.length) selected = 0;
    } 
    // ===========================
    //   SPACE untuk memilih
    // ===========================
    else if (keyCode == 32 && keySpace) {   // SPACE
      sin.freq(700);
      
      if (selected == 0) {
        if (ballSkin) println("DEFAULT dipilih");
        if (paddleSkin) println("DEFAULT dipilih");
        if (brickSkin) println("DEFAULT dipilih");
        
        if (ballSkin) BallTC = 0;
        if (paddleSkin) PaddleTC = 0;
        if (brickSkin) {
          chooseBrick = 0;
          //initializeBrickRows();
        }
      }
      else if (selected == 1 && highskor >= 500) {
        if (ballSkin) println("PARTY dipilih");
        if (paddleSkin) println("PARTY dipilih");
        if (brickSkin) println("GEMS dipilih");
        
        if (ballSkin) BallTC = 1;
        if (paddleSkin) PaddleTC = 1;
        if (brickSkin) {
          chooseBrick = 1;
          //initializeBrickRows();
        }
      }
      else if (selected == 2 && highskor >= 1000) {
        if (ballSkin) println("??? dipilih");
        if (paddleSkin) println("??? dipilih");
        if (brickSkin) println("METALLIC dipilih");
        
        if (ballSkin) BallTC = 2;
        if (paddleSkin) PaddleTC = 2;
        if (brickSkin) {
          chooseBrick = 2;
          //initializeBrickRows();
        }
      }
      else {
        sin.freq(990);
        println("skor tidak cukup");
      }
      //if ((selected == 1 && highskor < 500) || (selected == 2 && highskor < 1000)) {
      if (selected < 3) {
        timer = millis(); // Set waktu mulai
      }
      keySpace = false;
    }
  }
  
  if (setting) {
      sin.play();
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    if (keyCode == UP || key == 'W' || key == 'w') {
      sin.freq(350);
      selected--;
      if (selected < 0) selected = menuSetting.length - 1;
    }
    else if (keyCode == DOWN || key == 'S' || key == 's') {
      sin.freq(350);
      selected++;
      if (selected >= menuSetting.length) selected = 0;
    } 
    // ===========================
    //   SPACE untuk memilih
    // ===========================
    else if (keyCode == 32 && keySpace) {   // SPACE
      sin.freq(700);
    
      if (selected == 0) {
        println("AUDIO dipilih");
        setting = false;
        audio = true;
        selected = int(volume * 10) - 1;
      }
      if (selected == 1) {
        println("BRIGHTNESS dipilih");
        setting = false;
        brightness = true;
        selected = 0;
      }
      if (selected == 2) {
        println("CREDIT dipilih");
        setting = false;
        credits = true;
      }
      keySpace = false;
    }
  }
  
    if (audio) {
      sin.play();
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    if (key == 'a' || key == 'A' || keyCode == LEFT) {
      sin.freq(350);
      selected--;
      if (selected < 0) selected = 0;
    }
    else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
      sin.freq(350);
      selected++;
      if (selected >= Audio.length) selected = Audio.length - 1;
    } 
    // ===========================
    //   SPACE untuk memilih
    // ===========================
    else if (keyCode == 32 && keySpace) {   // SPACE
      sin.freq(700);
      volume = (selected + 1)/10f;
    }
  }
  
  if (!menu && !skin && !ballSkin && !paddleSkin && !brickSkin && !setting && !audio && !brightness && !credits && !mulai) {
    if (keyCode == 32 && keySpace) {
      sin.play();
      sin.freq(370);
      sin.amp(volume);
      env.play(sin, 0.05, 0.01, 0.3, 0.1);
      mulai = true;
      if (paused && savedVelocity != null) {
        velocity = savedVelocity.copy();
        paused = false;
      } else {
        // Only set random velocity if this is a fresh start
        velocity.x = random(2, 4) * (random(1) > 0.5 ? 1 : -1);
        if(stageBack == 0) velocity.y = -random(6, 8) * 1;
        if(stageBack == 1) velocity.y = -random(6, 8) * ((stageBack + 1) * 0.6);
        if(stageBack > 1) velocity.y = -random(6, 8) * ((stageBack + 1) * 0.5);
      }
      keySpace = false;
    }
  }
  
  if (key == 'a' || key == 'A' || keyCode == LEFT) keyA = true;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) keyD = true;
  if (key == ESC) {
    sin.play();
    sin.freq(220);
    sin.amp(volume);
    env.play(sin, 0.05, 0.01, 0.3, 0.1);
    key = 0;
    if (!menu && !(ballSkin || paddleSkin || brickSkin || audio || brightness || credits)) {
      println ("escape to menu");
      
      if (!skin) {
        savedVelocity = velocity.copy();
        paused = true;
      }
      
      menu = true;
      selected = 0;
      skin = false;
      setting = false;
    }
    else if (!menu && (ballSkin || paddleSkin || brickSkin)) {
      println ("escape to skin select");
      skin = true;
      selected = 0;
      ballSkin = false;
      paddleSkin = false;
      brickSkin = false;
    }
    else if (!menu && (audio || brightness || credits)) {
      println ("escape to setting select");
      setting = true;
      selected = 0;
      audio = false;
      brightness = false;
      credits = false;
    }
    else if (menu && first) {
      println ("menu escape");
      menu = false;
      if (paused && savedVelocity != null) {
        velocity = savedVelocity.copy();
        paused = false;
      } else {
        velocity.x = random(2, 4) * (random(1) > 0.5 ? 1 : -1);
        velocity.y = -random(6, 8);
      }
    }
    //else if (menu && !first) {
    //  println ("escape");
    //  exit();
    //}
  }
  
    // Handle alphanumeric keys
  if (Character.isLetterOrDigit(key)) {
    inputBuffer += key;
    lastKeyTime = millis();
    
    checkCheatCodes();
    
    // Keep buffer manageable
    if (inputBuffer.length() > 15) {
      inputBuffer = inputBuffer.substring(1);
    }
  }
}
