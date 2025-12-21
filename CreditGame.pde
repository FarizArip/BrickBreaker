// ===============================
//  CREDIT GAME — RETRO STYLE
// ===============================

boolean credit = false;

// ganti dengan logo kamu
PImage logoCredit;

void drawCredit() {
  if (credit && !setting) {

  background(20, 30, 50);
  fill(255);

  // ===================
  // LOGO (GAMBAR)
  // ===================
  imageMode(CENTER);
  image(logoCredit, width/2, 110, 100, 100);

  // ===================
  // JUDUL
  // ===================
  textAlign(CENTER);
  textSize(18);
  text("CREDITS", width/2, 170);

  keymapEsc();

  // ===================
  // NAMA PEMBUAT (STATIS)
  // ===================
  textAlign(CENTER);
  textSize(16);
  text("MAGNOLIA AZIZAH CARISSA", width/2, 230);
  text("(2407431051)", width/2, 250);
  text("MUHAMMAD FARIZ FADHILLAH", width/2, 305);
  text("(2407431043)", width/2, 325);
  text("REGAN ANANDA AKBAR ASSHIDQI", width/2, 370);
  text("(2407431041)", width/2, 390);

  // ===================
  // TOMBOL BACK
  // ===================
  float x = 100;
  float y = 430;

  if (jitterCooldown <= 0) {
    jitterX = random(-1.2, 1.2);
    jitterY = random(-1.2, 1.2);
    jitterCooldown = 10;
  } else {
    jitterCooldown--;
  }

  textSize(18);
  textAlign(LEFT, CENTER);
  text(">", x - 30, y);
  text("BACK", x + jitterX, y + jitterY);

  // ===================
  // GAME BERHENTI
  // ===================
  velocity.x = 0;
  velocity.y = 0;
  }
}
