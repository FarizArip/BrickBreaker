import java.util.*;

HashMap<String, Runnable> cheatCodes = new HashMap<String, Runnable>();
String inputBuffer = "";
int lastKeyTime = 0;
final int TIMEOUT = 2000;

void checkCheatCodes() {
  for (String code : cheatCodes.keySet()) {
    if (inputBuffer.toLowerCase().endsWith(code)) {
      println("Cheat activated: " + code);
      cheatCodes.get(code).run();
      inputBuffer = "";
      break;
    }
  }
}

void addHealth() {
  nyawa += 100;
}
void kill() {
  nyawa = 0;
  gameOver = true;
}
void score() {
  skor += 100;
}
void brick() {
  for (int i = 0; i < brickRows; i++) {
    for (int j = 0; j < brickCols; j++) {
      bricks[i][j] = false;
    }
  }
}
