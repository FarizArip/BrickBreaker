boolean skin = false;
boolean ballSkin = false;
boolean paddleSkin = false;
boolean brickSkin = false;

String[] menuSkin = { "Ball", "Paddle", "Brick" };
String[] Ballskins = { "DEFAULT", "GOLD", "DIAMOND" };      
String[] Paddleskins = { "DEFAULT", "HAZARD", "RITZ" };      
String[] Brickskins = { "DEFAULT", "GEMS", "METALLIC" };      
String[] points = { "0", "500", "1000" };
//import gifAnimation.*;
PImage[] ballS;
PImage[] slider;
PImage[] Bricks;
PImage[][] rowBrickImages;

//Gif rainbow;
int chooseBall = 0;
int choosePaddle = 0;
int chooseBrick = 0;
int BallTC = 0;
int PaddleTC = 0;

void drawSkin() {
  if (skin) {
    background(20, 30, 50);
    fill(255);
  
    // Judul
    textAlign(CENTER);
    textSize(27);
    text("Pilih Jenis", width/2, 160);
    
    // Menu
    textSize(18);
    keymapEsc();
    keymapUpDown();
    for (int i = 0; i < menuSkin.length; i++) {
  
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
      text(menuSkin[i], x, y);
    }
    velocity.x = 0;
    velocity.y = 0;
  }
  
  if ((ballSkin || paddleSkin || brickSkin) && !skin) {
    background(20, 30, 50);
    fill(255);
  
    // Judul
    textAlign(CENTER);
    textSize(27);
    text("Pilih Skin", width/2, 160);
    
    textSize(16);
    text("Points", 400, 200);
    
    // Menu
    float xBall = 300;
    float xPoint = 350;
    
    textSize(18);
    int Seleksi = Ballskins.length;
    String[] nama = Ballskins;
    PImage[] item = ballS;
    
    if (ballSkin) {
      Seleksi = Ballskins.length;
      nama = Ballskins;
      item = ballS;
    } else if (paddleSkin) {
      Seleksi = Paddleskins.length;
      nama = Paddleskins;
      item = slider;
    } else if (brickSkin) {
      Seleksi = Brickskins.length;
      nama = Brickskins;
      item = Bricks;
    }
    
    
    keymapEsc();
    keymapUpDown();
    // Single loop for the active skin type
    for (int i = 0; i < Seleksi; i++) {
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
      textSize(16);
      text(nama[i], x, y);
      
      // Draw image based on skin type
      if (ballSkin) {
        image(item[i], xBall, y, ballDia, ballDia);
      } else if (paddleSkin) {
        image(item[i], xBall - 10, y, paddleWidth/1.5f, paddleHeight - 3);
      } else if (brickSkin) {
        image(item[i], xBall, y, brickWidth - 5, brickHeight - 5);
      }
      
      text(points[i], xPoint, y);
      text("Points Anda : " + highskor, width/2 - 150, height/2+100);
    }
    velocity.x = 0;
    velocity.y = 0;
  }
}

int timer = 0;

void poinCukup() {
  if (ballSkin || paddleSkin || brickSkin) {
    if (millis() - timer < 3000) {
      if ((keyCode == UP || key == 'W' || key == 'w') || (keyCode == DOWN || key == 'S' || key == 's')) {
        timer = 0;
      }else if ((selected == 1 && highskor < 500) || (selected == 2 && highskor < 1000)) {
        textSize(16);
        text("Skor tidak cukup!", width/2 - 150, height/2+150);
      } else {
        textSize(14);
        text("Skin akan diterapkan \npada stage berikutnya\natau restart!", width/2 - 150, height/2+150);
      }
    }
  }
}

void drawTextWithStroke(String txt, float x, float y, 
                        int strokeColor, int fillColor, 
                        float strokeWeight) {
  
  pushStyle();
  
  // Method 1: Draw stroke first with fill, then main text on top
  stroke(strokeColor);
  strokeWeight(strokeWeight);
  fill(strokeColor);  // IMPORTANT: Fill with stroke color for the outline!
  
  // Draw the stroke version (slightly larger or offset)
  for (int i = -1; i <= 1; i++) {
    for (int j = -1; j <= 1; j++) {
      if (i != 0 || j != 0) {
        text(txt, x + i, y + j);
      }
    }
  }
  
  // Draw the main fill text on top
  noStroke();
  fill(fillColor);
  text(txt, x, y);
  
  popStyle();
}
