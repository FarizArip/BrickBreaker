PVector location;  // lokasinya
PVector velocity;  // kecepatannya
PVector savedVelocity;

float ballDia = 30;       // jari-jari ball

float paddleX, paddleY;
float paddleWidth = 120, paddleHeight = 15;

int skor = 0;
int highskor = 0;
int stage = 1;
int nyawa = 3;
boolean gameOver = false;
boolean mulai = false;

boolean menungguLevelBaru = false;
int waktuMulaiTunggu = 0;

PImage[] Background;
int stageBack;
PFont retroFont;

int brickRows = 5;
int brickCols = 8;
boolean[][] bricks;
float brickWidth, brickHeight;

boolean keyA = false;
boolean keyD = false;
boolean keySpace = true;
boolean paused = false;

float rot = 0;

float anim = 600;
float animText = 900;

import processing.sound.*;
TriOsc sin;
Env env;

void setup() {
  size(500, 600);
  location = new PVector(width/2, height/2);
  velocity = new PVector(0, 0);
  paddleX = width/2 - paddleWidth/2;
  paddleY = height - 50;
  imageMode(CENTER);
  
  Background = new PImage[5];
  Background[0] = loadImage("background/beach.jpg");
  Background[1] = loadImage("background/city.jpg");
  Background[2] = loadImage("background/mountain.jpg");
  Background[3] = loadImage("background/sky.jpg");
  Background[4] = loadImage("background/galaxy.jpg");
  
  ballS = new PImage[3];
  ballS[0] = loadImage("ball/balldefault.png");
  ballS[1] = loadImage("ball/ballgold.png");
  ballS[2] = loadImage("ball/balldiamond.png");
  //rainbow = new Gif(this, "bull.gif");
  //rainbow.play();
  //ballS[2] = rainbow;
  
  slider = new PImage[3];
  slider[0] = loadImage("slider/sliderdefault.png");
  slider[1] = loadImage("slider/sliderskin1.png");
  slider[2] = loadImage("slider/sliderskin2.png");
  
  Bricks = new PImage[3];
  Bricks[0] = loadImage("brick/default/defaultbrick1.png");
  Bricks[1] = loadImage("brick/gems/gemsbrick1.png");
  Bricks[2] = loadImage("brick/metallic/metallicbrick1.png");
  initializeBrickRows();
  
  // Inisialisasi array bricks
  bricks = new boolean[brickRows][brickCols];
  brickWidth = 59;
  brickHeight = 25;
  
  for (int i = 0; i < brickRows; i++) {
    for (int j = 0; j < brickCols; j++) {
      bricks[i][j] = true;
    }
  }
  
  retroFont = createFont("PressStart2P.ttf", 20);
  //noCursor(); // hilangkan mouse
  
  sin = new TriOsc(this);
  env = new Env(this);
  cheatCodes.put("health", this::addHealth);
  cheatCodes.put("killme", this::kill);
  cheatCodes.put("mygo", this::score);
  cheatCodes.put("bricked", this::brick);
  windowTitle("BrickBreaker");
}

void draw() {
  background(50);
  stageBack = stage-1;
  if (stageBack > 4) stageBack = 0;
  if (!mulai || menungguLevelBaru) tint(255, 50);
  if (mulai && !menungguLevelBaru) tint (255, 150);
  image(Background[stageBack], width/2, height/2, width, height);
  tint(255, 255);
  fill(#ffffff);
  
  awalMulai();
  
  if (menungguLevelBaru) {
    prosesJedaLevel();
    return; // Berhenti sementara di frame ini
  }
  
  // tambahin kecepatan ke lokasinya
  if (mulai && !gameOver) {
    location.add(velocity);
  // mantul kiri-kanan
    if ((location.x > width - ballDia/2) || (location.x < ballDia/2)) {
      velocity.x *= -1;
      // ketentuan batas pantulan
      if (location.x > width - ballDia/2) location.x = width - ballDia/2;
      if (location.x < ballDia/2) location.x = ballDia/2;
      sin.play();
      sin.freq(160);
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    }

    // mantul bawah
    //if (location.y > height - ballDia/2) {
    //  velocity.y = velocity.y * -0.95;
    //  location.y = height - ballDia/2;
    //}
    
    if (location.y > height + ballDia) {
      nyawa--;
      sin.play();
      sin.freq(670);
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
      if (nyawa <= 0) {
        gameOver = true;
      } else {
        Mati();
      }
    }
    
    // Bounce off top
    if (location.y < ballDia/2) {
      velocity.y *= -1;
      location.y = ballDia/2;
      sin.play();
      sin.freq(160);
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    }

     if (deteksiTumbukanPaddle()) {
      velocity.y = -abs(velocity.y);
      float hitPos = (location.x - paddleX) / paddleWidth;
      velocity.x = (hitPos - 0.5) * 8;
      sin.play();
      sin.freq(320);
      sin.amp(volume);
      env.play(sin, 0.005, 0.01, 0.5, 0.085);
    }
    
    boolean adaTumbukan = false;
    for (int i = 0; i < brickRows; i++) {
      for (int j = 0; j < brickCols; j++) {
        if (bricks[i][j]) { // Cek jika brick masih aktif
          float brickX = j * brickWidth + 16;
          float brickY = i * brickHeight + 40; // Offset dari atas
          
          // Deteksi tumbukan
          if (deteksiTumbukanBrick(brickX, brickY, brickWidth, brickHeight)) {
            
            bricks[i][j] = false; // Nonaktifkan brick
            skor += 10; // Tambah skor
            sin.play();
            sin.freq(440);
            sin.amp(volume);
            env.play(sin, 0.005, 0.01, 0.5, 0.085);
            adaTumbukan = true;
            break;
          }
        }
      }
      if (adaTumbukan) break;
    }
    skorHi();
  }

  fill(127);
  gambarBricks();
  cekBrick();
  
  // Bola
  stroke(255);
  strokeWeight(2);
  fill(127);
  pushMatrix();
  if (mulai) {
  translate(location.x, location.y);
  rotate(rot);
  translate(-location.x, -location.y);
  }
  image(ballS[chooseBall], location.x, location.y, ballDia, ballDia);
  popMatrix();
  rot += 0.5;

  // Paddle
  //paddleX = mouseX - paddleWidth/2;
  Keyboard();
  paddleX = constrain(paddleX, 0, width - paddleWidth);
  image(slider[choosePaddle], paddleX+60, paddleY, paddleWidth, paddleHeight);

  Restart();
  if (gameOver) anim -= 10;
  if (gameOver) animText -= 10;
  
  textFont(retroFont);
  //fill(#ffffff);
  //text("Skor: " + skor + "  Nyawa: " + nyawa, width/2, 10);
  drawTextWithStroke("Skor: " + skor + "  Nyawa: " + nyawa, width/2, 10, 
    0, 255, 5);
  textAlign(CENTER, TOP);
  textSize(30);
  GameOver();
  
  drawMenu();
  drawSkin();
  drawSetting();
  poinCukup();
  if (millis() - lastKeyTime > TIMEOUT && !inputBuffer.isEmpty()) {
    inputBuffer = "";
  }
}

void prosesJedaLevel() {
  // Gambar bricks yang sudah ada
  gambarBricks();
  
  // Gambar paddle dan bola
  ellipse(location.x, location.y, ballDia, ballDia);
  rect(paddleX, paddleY, paddleWidth, paddleHeight);
  
  // Tampilkan pesan
  fill(255, 255, 0);
  textSize(24);
  //text("STAGE " + stage, width/2, height/2 - 50);
  drawTextWithStroke("STAGE " + stage, width/2, height/2 - 50, 
    0, color(255, 255, 0), 5);
  textSize(16);
  //text("Memulai dalam: " + ((3000 - (millis() - waktuMulaiTunggu)) / 1000 + 1), width/2, height/2);
  drawTextWithStroke("Memulai dalam: " + ((3000 - (millis() - waktuMulaiTunggu)) / 1000 + 1), width/2, height/2, 
    0, color(255, 255, 0), 5);
  
  // Cek jika waktu tunggu sudah selesai
  if (millis() - waktuMulaiTunggu > 3000) { // 3 detik
    menungguLevelBaru = false;
    mulai = false;
    paddleX = width/2 - paddleWidth/2;
  }
}

boolean deteksiTumbukanPaddle() {
  // Titik terdekat pada paddle ke pusat bola
  float closestX = constrain(location.x, paddleX, paddleX + paddleWidth);
  float closestY = constrain(location.y, paddleY, paddleY + paddleHeight);
  
  // Jarak dari titik terdekat ke pusat bola
  float distanceX = location.x - closestX;
  float distanceY = location.y - closestY;
  float distance = sqrt(distanceX * distanceX + distanceY * distanceY);
  
  return distance < ballDia/2;
}

boolean deteksiTumbukanBrick(float brickX, float brickY, float brickW, float brickH) {
  // Titik terdekat pada brick ke pusat bola
  float closestX = constrain(location.x, brickX, brickX + brickW);
  float closestY = constrain(location.y, brickY, brickY + brickH);
  
  // Jarak dari titik terdekat ke pusat bola
  float distanceX = location.x - closestX;
  float distanceY = location.y - closestY;
  float distance = sqrt(distanceX * distanceX + distanceY * distanceY);
  
  if (distance < ballDia/2) {
    // Tentukan sisi mana yang ditabrak untuk pantulan yang tepat
    float overlapLeft = (location.x + ballDia/2) - brickX;
    float overlapRight = (brickX + brickW) - (location.x - ballDia/2);
    float overlapTop = (location.y + ballDia/2) - brickY;
    float overlapBottom = (brickY + brickH) - (location.y - ballDia/2);
    
    float minHorizontal = min(overlapLeft, overlapRight);
    float minVertical = min(overlapTop, overlapBottom);
    
    if (minHorizontal < minVertical) {
      velocity.x *= -1;
    } else {
      velocity.y *= -1;
    }
    
    return true;
  }
  return false;
}

void gambarBricks() {
  for (int i = 0; i < brickRows; i++) {
    for (int j = 0; j < brickCols; j++) {
      if (bricks[i][j]) { // Hanya gambar brick yang aktif
        float brickX = j * brickWidth + 43.5;
        float brickY = i * brickHeight + 50;
        
        // Use the row-specific image from the 2D array
        if (rowBrickImages[i][j] != null) {
          image(rowBrickImages[i][j], brickX, brickY, brickWidth - 5, brickHeight - 5);
        } else {
          // Fallback to the selected brick skin
          image(Bricks[chooseBrick], brickX, brickY, brickWidth - 5, brickHeight - 5);
        }
        
        if (menungguLevelBaru) {
          rect(brickX - 30, brickY - 10, brickWidth - 4, brickHeight - 5);
        }
      }
    }
  }
}

void initializeBrickRows() {
  rowBrickImages = new PImage[brickRows][];
  
  for (int i = 0; i < brickRows; i++) {
    rowBrickImages[i] = new PImage[brickCols];
    
    // Choose different brick variations for each row based on selected skin
    int rowType = i % 4;
    
    for (int j = 0; j < brickCols; j++) {
      if (chooseBrick == 0) {
        if (rowType == 0) {
          rowBrickImages[i][j] = loadImage("brick/default/defaultbrick1.png");
        } else if (rowType == 1) {
          rowBrickImages[i][j] = loadImage("brick/default/defaultbrick2.png");
        } else if (rowType == 2) {
          rowBrickImages[i][j] = loadImage("brick/default/defaultbrick3.png");
        } else {
          rowBrickImages[i][j] = loadImage("brick/default/defaultbrick4.png");
        }
      } else if (chooseBrick == 1) {
        if (rowType == 0) {
          rowBrickImages[i][j] = loadImage("brick/gems/gemsbrick1.png");
        } else if (rowType == 1) {
          rowBrickImages[i][j] = loadImage("brick/gems/gemsbrick2.png");
        } else if (rowType == 2) {
          rowBrickImages[i][j] = loadImage("brick/gems/gemsbrick3.png");
        } else {
          rowBrickImages[i][j] = loadImage("brick/gems/gemsbrick4.png");
        }
      } else if (chooseBrick == 2) {
        if (rowType == 0) {
          rowBrickImages[i][j] = loadImage("brick/metallic/metallicbrick1.png");
        } else if (rowType == 1) {
          rowBrickImages[i][j] = loadImage("brick/metallic/metallicbrick2.png");
        } else if (rowType == 2) {
          rowBrickImages[i][j] = loadImage("brick/metallic/metallicbrick3.png");
        } else {
          rowBrickImages[i][j] = loadImage("brick/metallic/metallicbrick4.png");
        }
      }
    }
  }
}

void skorHi() {
  if (skor > highskor ) {
    highskor = skor;
  }
}

void awalMulai() {
 if (!mulai && !gameOver) {
   velocity.x = 0;
   velocity.y = 0;
   location.x = paddleX + paddleWidth/2;
   location.y = paddleY - 30;
   
   textSize(16);
   //text("Pencet 'Space' untuk mulai", width/2, 350);
   drawTextWithStroke("Pencet 'Space' untuk mulai", width/2, 350, 
    0, 255, 5);
   
 }
}

void cekBrick() {
  boolean semuaHancur = true;
  for (int i = 0; i < brickRows; i++) {
    for (int j = 0; j < brickCols; j++) {
      if (bricks[i][j]) {
        semuaHancur = false;
        break;
      }
    }
    if (!semuaHancur) break;
  }
  
  if (semuaHancur && !menungguLevelBaru) {
    menungguLevelBaru = true;
    waktuMulaiTunggu = millis();
    stage++;
    initializeBrickRows();
    chooseBall = BallTC;
    choosePaddle = PaddleTC;
    for (int i = 0; i < brickRows; i++) {
      for (int j = 0; j < brickCols; j++) {
        bricks[i][j] = true;
      }
    }
  }
}

void GameOver() {
  if (gameOver && !menu) {
    fill(#000000);
    noStroke();
    rect(0, anim, width, height+7);
    if (anim < 0) anim = 0;
    fill(#ff0000);
    text("Game Over", width/2, animText);
    if (animText < 200) animText = 200;
    textSize(18);
    text("Press 'R' to restart", width/2, (animText)+40);
    textSize(16);
    text("Skor: " + skor, width/2, (animText)+80);
    text("High Skor: " + highskor, width/2, (animText)+100);
  }
}

void Mati() {
   mulai = false;
   location.x = paddleX + paddleWidth/2;
   location.y = paddleY - 30;
}

void Restart() {
  if (keyPressed && gameOver == true && (!menu && !skin && !ballSkin && !paddleSkin && !brickSkin)) {
   if (key == 'R' || key == 'r') {
     skor = 0;
     stage = 1;
     nyawa = 3;
     initializeBrickRows();
     chooseBall = BallTC;
     choosePaddle = PaddleTC;
     location.x = paddleX + paddleWidth/2;
     location.y = paddleY - 30;
     paddleX = width/2 - paddleWidth/2;
     gameOver = false;
     mulai = false;
     anim = 600;
     animText = 900;
     
     for (int i = 0; i < brickRows; i++) {
      for (int j = 0; j < brickCols; j++) {
        bricks[i][j] = true;
      }
     }
   }
  }
}

void Keyboard() {
  float speed = 8;
  if (!menu) {
      if (keyA) {
        paddleX -= speed;
    } if (keyD) {
        paddleX += speed;
    }
  }
}

void keyReleased() {
  if (key == 'a' || key == 'A' || keyCode == LEFT) keyA = false;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) keyD = false;
  if (keyCode == 32) keySpace = true;
}
