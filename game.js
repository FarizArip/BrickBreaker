// ==================== GLOBAL VARIABLES ====================
let ballLocation;
let velocity;
let savedVelocity;
let ballDia = 30;
let paddleX, paddleY;
let paddleWidth = 120, paddleHeight = 15;

let skor = 0;
let highskor = 0;
let stage = 1;
let nyawa = 3;
let gameOver = false;
let mulai = false;
let menungguLevelBaru = false;
let waktuMulaiTunggu = 0;

let Background = [];
let stageBack;
let brickRows = 5;
let brickCols = 8;
let bricks = [];
let brickWidth, brickHeight;
let defaultBrickVar1, defaultBrickVar2, defaultBrickVar3, defaultBrickVar4;
let gemsBrickVar1, gemsBrickVar2, gemsBrickVar3, gemsBrickVar4;
let metallicBrickVar1, metallicBrickVar2, metallicBrickVar3, metallicBrickVar4;

let keyA = false;
let keyD = false;
let keySpace = true;
let paused = false;
let rot = 0;
let anim = 600;
let animText = 900;

// Menu variables
let menuItems = ["START", "CHANGE SKIN", "QUIT"];
let selected = 0;
let jitterCooldown = 0;
let jitterX = 0, jitterY = 0;
let menu = true;
let first = false;

// Skin variables
let skin = false;
let ballSkin = false;
let paddleSkin = false;
let brickSkin = false;
let menuSkin = ["Ball", "Paddle", "Brick"];
let Ballskins = ["DEFAULT", "GOLD", "DIAMOND"];
let Paddleskins = ["DEFAULT", "HAZARD", "RITZ"];
let Brickskins = ["DEFAULT", "GEMS", "METALLIC"];
let points = ["0", "500", "1000"];
let ballS = [];
let slider = [];
let Bricks = []; // This stores the MAIN brick image for the current skin
let rowBrickImages = []; // This stores INDIVIDUAL brick images for EACH brick position
let chooseBall = 0;
let choosePaddle = 0;
let chooseBrick = 0;
let BallTC = 0;
let PaddleTC = 0;
let timer = 0;

// Sound manager
let soundManager;
let soundEnabled = true;

// Font
let gameFont;

// Cheat codes
let inputBuffer = "";
let lastKeyTime = 0;
const TIMEOUT = 2000;

// DOM elements
let currentScoreEl, highScoreEl, soundToggleBtn, fullscreenBtn;

// ==================== SOUND MANAGER CLASS ====================
class SoundManager {
    constructor() {
        this.sounds = {
            menuNav: { freq: 350, type: 'triangle' },
            menuSelect: { freq: 700, type: 'triangle' },
            wallBounce: { freq: 160, type: 'triangle' },
            paddleBounce: { freq: 320, type: 'triangle' },
            brickBreak: { freq: 440, type: 'triangle' },
            loseLife: { freq: 670, type: 'triangle' },
            gameStart: { freq: 370, type: 'triangle' },
            error: { freq: 990, type: 'triangle' },
            escape: { freq: 220, type: 'triangle' }
        };
        
        this.isPlaying = false;
        this.audioContextAllowed = false;
    }
    
    play(soundName) {
        if (!soundEnabled || this.isPlaying || !this.audioContextAllowed) return;
        
        const sound = this.sounds[soundName];
        if (!sound) return;
        
        this.isPlaying = true;
        
        try {
            const osc = new p5.Oscillator(sound.type);
            const env = new p5.Envelope();
            
            osc.freq(sound.freq);
            osc.amp(0);
            
            env.setADSR(0.005, 0.01, 0.5, 0.085);
            env.setRange(0.3, 0);
            
            osc.start();
            env.play(osc);
            
            setTimeout(() => {
                osc.stop();
                osc.dispose();
                this.isPlaying = false;
            }, 100);
        } catch (e) {
            console.log("Sound error:", e);
            this.isPlaying = false;
        }
    }
    
    enableAudio() {
        this.audioContextAllowed = true;
        if (getAudioContext().state !== 'running') {
            getAudioContext().resume();
        }
    }
    
    toggle() {
        soundEnabled = !soundEnabled;
        return soundEnabled;
    }
}

soundManager = new SoundManager();

// ==================== PRELOAD data ====================
function preload() {
    gameFont = loadFont('data/PressStart2P.ttf');
    
    // Load background images
    Background[0] = loadImage('data/background/beach.jpg');
    Background[1] = loadImage('data/background/city.jpg');
    Background[2] = loadImage('data/background/mountain.jpg');
    Background[3] = loadImage('data/background/sky.jpg');
    Background[4] = loadImage('data/background/galaxy.jpg');
    
    // Load ball images
    ballS[0] = loadImage('data/ball/balldefault.png');
    ballS[1] = loadImage('data/ball/ballgold.png');
    ballS[2] = loadImage('data/ball/balldiamond.png');
    
    // Load paddle images
    slider[0] = loadImage('data/slider/sliderdefault.png');
    slider[1] = loadImage('data/slider/sliderskin1.png');
    slider[2] = loadImage('data/slider/sliderskin2.png');
    
    // Load MAIN brick images for each skin (for menu preview)
    Bricks[0] = loadImage('data/brick/default/defaultbrick1.png');  // DEFAULT
    Bricks[1] = loadImage('data/brick/gems/gemsbrick1.png');        // GEMS
    Bricks[2] = loadImage('data/brick/metallic/metallicbrick1.png'); // METALLIC

    // DEFAULT brick variations
    defaultBrickVar1 = loadImage('data/brick/default/defaultbrick1.png');
    defaultBrickVar2 = loadImage('data/brick/default/defaultbrick2.png');
    defaultBrickVar3 = loadImage('data/brick/default/defaultbrick3.png');
    defaultBrickVar4 = loadImage('data/brick/default/defaultbrick4.png');
    
    // GEMS brick variations  
    gemsBrickVar1 = loadImage('data/brick/gems/gemsbrick1.png');
    gemsBrickVar2 = loadImage('data/brick/gems/gemsbrick2.png');
    gemsBrickVar3 = loadImage('data/brick/gems/gemsbrick3.png');
    gemsBrickVar4 = loadImage('data/brick/gems/gemsbrick4.png');
    
    // METALLIC brick variations
    metallicBrickVar1 = loadImage('data/brick/metallic/metallicbrick1.png');
    metallicBrickVar2 = loadImage('data/brick/metallic/metallicbrick2.png');
    metallicBrickVar3 = loadImage('data/brick/metallic/metallicbrick3.png');
    metallicBrickVar4 = loadImage('data/brick/metallic/metallicbrick4.png');

        // Add warning if fonts fail to load
    if (!gameFont) {
        console.warn("Game font failed to load. Using system monospace.");
    }
    
    // Check if essential images loaded
    if (!ballS[0] || !slider[0] || !Bricks[0]) {
        console.error("Essential game assets failed to load!");
    }
}

// ==================== SETUP ====================
function setup() {
    const canvas = createCanvas(500, 600);
    canvas.parent('game-container');
    
    currentScoreEl = document.getElementById('current-score');
    highScoreEl = document.getElementById('high-score');
    soundToggleBtn = document.getElementById('sound-toggle');
    fullscreenBtn = document.getElementById('fullscreen');
    
    if (soundToggleBtn) {
        soundToggleBtn.addEventListener('click', function() {
            toggleSound();
            soundManager.enableAudio();
        });
        soundToggleBtn.textContent = soundEnabled ? '🔊 Sound: ON' : '🔇 Sound: OFF';
    }
    
    if (fullscreenBtn) {
        fullscreenBtn.addEventListener('click', function() {
            toggleFullscreen();
            soundManager.enableAudio();
        });
        fullscreenBtn.textContent = '⛶ Fullscreen';
    }
    
    paddleX = width / 2 - paddleWidth / 2;
    paddleY = height - 50;
    
    ballLocation = createVector(paddleX + paddleWidth / 2, paddleY - 30);
    velocity = createVector(0, 0);
    savedVelocity = createVector(0, 0);

    brickWidth = 59;
    brickHeight = 25;
    bricks = Array(brickRows).fill().map(() => Array(brickCols).fill(true));
    
    if (gameFont) {
        textFont(gameFont);
    } else {
        textFont('monospace');
    }
    
    // Initialize brick rows with images
    initializeBrickRows();
    
    textAlign(CENTER, CENTER);
    textSize(16);
    imageMode(CENTER);
    
    window.addEventListener('keydown', function(e) {
        if([32, 37, 38, 39, 40].indexOf(e.keyCode) > -1) {
            e.preventDefault();
        }
        soundManager.enableAudio();
    }, false);
}

// ==================== DRAW ====================
function draw() {
    if (currentScoreEl) currentScoreEl.textContent = skor;
    if (highScoreEl) highScoreEl.textContent = highskor;
    
    background(20, 30, 50);
    
    stageBack = stage - 1;
    if (stageBack > 4) stageBack = 0;
    
    drawStageBackground();
    
    if (menungguLevelBaru) {
        prosesJedaLevel();
        return;
    }
    
    if (mulai && !gameOver) {
        updateGame();
    }
    
    drawBricks();  // This should now show actual brick images
    drawBall();
    drawPaddle();
    
    checkLevelComplete();
    
    drawUI();
    
    if (menu) drawMenu();
    if (skin) drawSkinSelection();
    if (ballSkin || paddleSkin || brickSkin) drawSkinChooser();
    
    poinCukup();
    
    if (millis() - lastKeyTime > TIMEOUT && inputBuffer.length > 0) {
        inputBuffer = "";
    }
}

// ==================== GAME LOGIC ====================
function updateGame() {
    ballLocation.add(velocity);
    
    if (ballLocation.x > width - ballDia/2 || ballLocation.x < ballDia/2) {
        velocity.x *= -1;
        ballLocation.x = constrain(ballLocation.x, ballDia/2, width - ballDia/2);
        soundManager.play('wallBounce');
    }
    
    if (ballLocation.y < ballDia/2) {
        velocity.y *= -1;
        ballLocation.y = ballDia/2;
        soundManager.play('wallBounce');
    }
    
    if (ballLocation.y > height + ballDia) {
        nyawa--;
        soundManager.play('loseLife');
        if (nyawa <= 0) {
            gameOver = true;
        } else {
            resetBall();
        }
    }
    
    if (deteksiTumbukanPaddle()) {
        velocity.y = -abs(velocity.y);
        let hitPos = (ballLocation.x - paddleX) / paddleWidth;
        velocity.x = (hitPos - 0.5) * 8;
        soundManager.play('paddleBounce');
    }
    
    for (let i = 0; i < brickRows; i++) {
        for (let j = 0; j < brickCols; j++) {
            if (bricks[i][j]) {
                let brickX = j * brickWidth + 43.5;
                let brickY = i * brickHeight + 50;
                
                if (deteksiTumbukanBrick(brickX, brickY, brickWidth - 5, brickHeight - 5)) {
                    bricks[i][j] = false;
                    skor += 10;
                    soundManager.play('brickBreak');
                    return;
                }
            }
        }
    }
    
    if (skor > highskor) {
        highskor = skor;
    }
}

function drawStageBackground() {
    if (Background[stageBack]) {
        if (!mulai || menungguLevelBaru) tint(255, 50);
        if (mulai && !menungguLevelBaru) tint(255, 150);
        image(Background[stageBack], width/2, height/2);
        tint(255, 255);
    } else {
        push();
        noStroke();
        
        switch(stageBack) {
            case 0:
                for (let i = 0; i < height; i++) {
                    let inter = map(i, 0, height, 0, 1);
                    let c = lerpColor(color(135, 206, 235), color(255, 228, 181), inter);
                    stroke(c);
                    line(0, i, width, i);
                }
                break;
            case 1:
                fill(100, 149, 237);
                rect(0, 0, width, height);
                break;
            case 2:
                fill(70, 130, 180);
                rect(0, 0, width, height);
                break;
            case 3:
                fill(135, 206, 250);
                rect(0, 0, width, height);
                break;
            case 4:
                fill(25, 25, 112);
                rect(0, 0, width, height);
                fill(255);
                for (let i = 0; i < 50; i++) {
                    ellipse(random(width), random(height), 2, 2);
                }
                break;
        }
        pop();
    }
}

// ==================== DRAW BRICKS ====================
function drawBricks() {
    for (let i = 0; i < brickRows; i++) {
        for (let j = 0; j < brickCols; j++) {
            if (bricks[i][j]) {
                let brickX = j * brickWidth + 43.5;
                let brickY = i * brickHeight + 50;
                
                // Draw the brick image from rowBrickImages array
                if (rowBrickImages[i] && rowBrickImages[i][j]) {
                    image(rowBrickImages[i][j], brickX, brickY, brickWidth - 5, brickHeight - 5);
                } 
                // Fallback: Use the main brick image
                else if (Bricks[chooseBrick]) {
                    image(Bricks[chooseBrick], brickX, brickY, brickWidth - 5, brickHeight - 5);
                }
                // Ultimate fallback: colored rectangle
                else {
                    push();
                    if (chooseBrick === 0) fill(200, 100, 100);
                    else if (chooseBrick === 1) fill(100, 200, 200);
                    else fill(150, 150, 150);
                    stroke(150, 50, 50);
                    strokeWeight(2);
                    rect(brickX, brickY, brickWidth - 5, brickHeight - 5);
                    pop();
                }
            }
        }
    }
}

// ==================== INITIALIZE BRICK ROWS WITH IMAGES ====================
function initializeBrickRows() {
    rowBrickImages = Array(brickRows).fill().map(() => Array(brickCols));
    
    // For now, use the main brick image for all bricks
    // If you want variations, you need to preload them separately
    // for (let i = 0; i < brickRows; i++) {
    //     for (let j = 0; j < brickCols; j++) {
    //         // Use the main brick image for the selected skin
    //         // If you want variations, you would need to:
    //         // 1. Preload all variation images in preload()
    //         // 2. Store them in an array
    //         // 3. Select the appropriate one here
    //         rowBrickImages[i][j] = Bricks[chooseBrick];
    //     }
    // }
    
    // ALTERNATIVE: If you want to implement variation logic later, here's the structure:
    
    // Array of preloaded brick variation images for each skin type
    // You would need to preload these in preload() function
    const brickVariations = {
        0: [ // DEFAULT variations
            defaultBrickVar1, defaultBrickVar2, defaultBrickVar3, defaultBrickVar4
        ],
        1: [ // GEMS variations
            gemsBrickVar1, gemsBrickVar2, gemsBrickVar3, gemsBrickVar4
        ],
        2: [ // METALLIC variations
            metallicBrickVar1, metallicBrickVar2, metallicBrickVar3, metallicBrickVar4
        ]
    };
    
    for (let i = 0; i < brickRows; i++) {
        for (let j = 0; j < brickCols; j++) {
            if (brickVariations[chooseBrick]) {
                let variationIndex = (i + j) % brickVariations[chooseBrick].length;
                rowBrickImages[i][j] = brickVariations[chooseBrick][variationIndex];
            } else {
                rowBrickImages[i][j] = Bricks[chooseBrick];
            }
        }
    }
}

function drawBall() {
    push();
    if (mulai) {
        translate(ballLocation.x, ballLocation.y);
        rotate(rot);
        translate(-ballLocation.x, -ballLocation.y);
    }
    
    if (ballS[chooseBall]) {
        image(ballS[chooseBall], ballLocation.x, ballLocation.y, ballDia, ballDia);
    } else {
        fill(255, 100, 100);
        stroke(255);
        strokeWeight(2);
        ellipse(ballLocation.x, ballLocation.y, ballDia, ballDia);
    }
    pop();
    rot += 0.05;
}

function drawPaddle() {
    if (!menu) {
        if (keyA) paddleX -= 8;
        if (keyD) paddleX += 8;
    }
    paddleX = constrain(paddleX, 0, width - paddleWidth);
    
    if (slider[choosePaddle]) {
        image(slider[choosePaddle], paddleX + paddleWidth / 2, paddleY, paddleWidth, paddleHeight);
    } else {
        fill(100, 200, 100);
        stroke(50, 150, 50);
        strokeWeight(2);
        rect(paddleX, paddleY, paddleWidth, paddleHeight);
    }
}

function drawMenu() {
    fill(20, 30, 50, 200);
    noStroke();
    rect(0, 0, width, height);
    
    fill(255);
    textSize(34);
    text("BRICK BREAKER", width / 2, 120);
    
    textSize(16);
    text("High Score: " + highskor, width / 2, 170);
    
    textSize(18);
    for (let i = 0; i < menuItems.length; i++) {
        let x = 100;
        let y = 260 + i * 55;
        
        if (i === selected) {
            if (jitterCooldown <= 0) {
                jitterX = random(-1.2, 1.2);
                jitterY = random(-1.2, 1.2);
                jitterCooldown = 10;
            } else {
                jitterCooldown--;
            }
            
            textAlign(LEFT, CENTER);
            text(">", x - 30, y);
            
            x += jitterX;
            y += jitterY;
        }
        
        fill(i === selected ? color(255, 255, 0) : 255);
        text(menuItems[i], x, y);
        textAlign(CENTER, CENTER);
    }
    
    velocity.x = 0;
    velocity.y = 0;
}

function drawSkinChooser() {
    fill(20, 30, 50, 200);
    noStroke();
    rect(0, 0, width, height);
    
    fill(255);
    textSize(27);
    text("Pilih Skin", width / 2, 160);
    
    let skinArray, itemArray, pointCosts;
    if (ballSkin) {
        skinArray = Ballskins;
        itemArray = ballS;
        pointCosts = [0, 500, 1000];
    } else if (paddleSkin) {
        skinArray = Paddleskins;
        itemArray = slider;
        pointCosts = [0, 500, 1000];
    } else {
        skinArray = Brickskins;
        itemArray = Bricks;  // This shows the brick image in menu
        pointCosts = [0, 500, 1000];
    }
    
    textSize(16);
    text("Points", 400, 200);
    
    for (let i = 0; i < skinArray.length; i++) {
        let x = 100;
        let y = 240 + i * 55;
        
        if (i === selected) {
            if (jitterCooldown <= 0) {
                jitterX = random(-1.2, 1.2);
                jitterY = random(-1.2, 1.2);
                jitterCooldown = 10;
            } else {
                jitterCooldown--;
            }
            
            textAlign(LEFT, CENTER);
            text(">", x - 30, y);
            
            x += jitterX;
            y += jitterY;
        }
        
        fill(i === selected ? color(255, 255, 0) : 255);
        text(skinArray[i], x, y);
        
        // Show the brick image in menu preview
        if (itemArray[i]) {
            image(itemArray[i], 300, y, 
                  ballSkin ? ballDia : paddleSkin ? paddleWidth/1.5 : brickWidth-5, 
                  ballSkin ? ballDia : paddleSkin ? paddleHeight-3 : brickHeight-5);
        }
        
        text(pointCosts[i] + " Points", 350, y);
    }

    textSize(14);
    text("Points Anda: " + highskor, width / 2 - 150, height / 2 + 100);
    
    textAlign(CENTER, CENTER);
    velocity.x = 0;
    velocity.y = 0;
}

// ==================== DRAW SKIN SELECTION MENU ====================
function drawSkinSelection() {
    fill(20, 30, 50, 200);
    noStroke();
    rect(0, 0, width, height);
    
    fill(255);
    textSize(27);
    text("SELECT SKIN TYPE", width / 2, 160);
    
    textSize(18);
    for (let i = 0; i < menuSkin.length; i++) {
        let x = 100;
        let y = 240 + i * 55;
        
        if (i === selected) {
            if (jitterCooldown <= 0) {
                jitterX = random(-1.2, 1.2);
                jitterY = random(-1.2, 1.2);
                jitterCooldown = 10;
            } else {
                jitterCooldown--;
            }
            
            textAlign(LEFT, CENTER);
            text(">", x - 30, y);
            
            x += jitterX;
            y += jitterY;
        }

        fill(i === selected ? color(255, 255, 0) : 255);
        text(menuSkin[i], x, y);
        textAlign(CENTER, CENTER);
    }
    
    velocity.x = 0;
    velocity.y = 0;
}

function checkLevelComplete() {
    let semuaHancur = true;
    for (let i = 0; i < brickRows; i++) {
        for (let j = 0; j < brickCols; j++) {
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
        
        // Reset bricks
        bricks = Array(brickRows).fill().map(() => Array(brickCols).fill(true));
        
        // Apply selected skins
        chooseBall = BallTC;
        choosePaddle = PaddleTC;
        
        // Reinitialize brick rows with new skin
        initializeBrickRows();
    }
}

function deteksiTumbukanPaddle() {
    let closestX = constrain(ballLocation.x, paddleX, paddleX + paddleWidth);
    let closestY = constrain(ballLocation.y, paddleY, paddleY + paddleHeight);
    let distanceX = ballLocation.x - closestX;
    let distanceY = ballLocation.y - closestY;
    let distance = sqrt(distanceX * distanceX + distanceY * distanceY);
    return distance < ballDia / 2;
}

function deteksiTumbukanBrick(brickX, brickY, brickW, brickH) {
    let closestX = constrain(ballLocation.x, brickX, brickX + brickW);
    let closestY = constrain(ballLocation.y, brickY, brickY + brickH);
    let distanceX = ballLocation.x - closestX;
    let distanceY = ballLocation.y - closestY;
    let distance = sqrt(distanceX * distanceX + distanceY * distanceY);
    
    if (distance < ballDia / 2) {
        let overlapLeft = (ballLocation.x + ballDia / 2) - brickX;
        let overlapRight = (brickX + brickW) - (ballLocation.x - ballDia / 2);
        let overlapTop = (ballLocation.y + ballDia / 2) - brickY;
        let overlapBottom = (brickY + brickH) - (ballLocation.y - ballDia / 2);
        
        let minHorizontal = min(overlapLeft, overlapRight);
        let minVertical = min(overlapTop, overlapBottom);
        
        if (minHorizontal < minVertical) {
            velocity.x *= -1;
        } else {
            velocity.y *= -1;
        }
        
        return true;
    }
    return false;
}

function resetBall() {
    mulai = false;
    ballLocation.x = paddleX + paddleWidth / 2;
    ballLocation.y = paddleY - 30;
    velocity.set(0, 0);
}

function prosesJedaLevel() {
    // Draw current game state
    drawBricks();
    drawBall();
    drawPaddle();
    
    // Draw level transition message
    fill(255, 255, 0, 200);
    noStroke();
    rect(0, 0, width, height);
    
    fill(0);
    textSize(24);
    text("STAGE " + stage, width / 2, height / 2 - 50);
    
    let timeLeft = ceil((3000 - (millis() - waktuMulaiTunggu)) / 1000);
    textSize(16);
    text("Memulai dalam: " + (timeLeft > 0 ? timeLeft : 0), width / 2, height / 2);
    
    if (millis() - waktuMulaiTunggu > 3000) {
        menungguLevelBaru = false;
        mulai = false;
        paddleX = width / 2 - paddleWidth / 2;
    }
}

// ==================== KEYBOARD HANDLING ====================
function keyPressed() {
    soundManager.enableAudio();
    
    if (key.length === 1 && key.match(/[a-zA-Z0-9]/)) {
        inputBuffer += key.toLowerCase();
        lastKeyTime = millis();
        checkCheatCodes();
        
        if (inputBuffer.length > 15) {
            inputBuffer = inputBuffer.substring(1);
        }
    }
    
    // ESC key handling - SIMPLIFIED
    if (keyCode === ESCAPE) {
        soundManager.play('escape');
        
        // If in skin selection submenus, go back to skin selection
        if (ballSkin || paddleSkin || brickSkin) {
            ballSkin = false;
            paddleSkin = false;
            brickSkin = false;
            skin = true;
            selected = 0;
            return false;
        }
        
        // If in skin selection, go back to main menu
        if (skin) {
            skin = false;
            menu = true;
            selected = 0;
            return false;
        }
        
        // If in game (not in menu), pause and go to menu
        if (!menu && !gameOver) {
            savedVelocity.set(velocity.x, velocity.y);
            paused = true;
            velocity.set(0, 0);
            menu = true;
            selected = 0;
            return false;
        }
        
        // If in menu during gameplay, return to game
        if (menu && first) {
            menu = false;
            if (paused && savedVelocity.mag() > 0) {
                velocity.set(savedVelocity.x, savedVelocity.y);
                paused = false;
            }
            return false;
        }
        
        return false;
    }
    
    // Menu navigation
    if (menu) {
        if (keyCode === UP_ARROW || key === 'W' || key === 'w') {
            soundManager.play('menuNav');
            selected--;
            if (selected < 0) selected = menuItems.length - 1;
        } else if (keyCode === DOWN_ARROW || key === 'S' || key === 's') {
            soundManager.play('menuNav');
            selected++;
            if (selected >= menuItems.length) selected = 0;
        } else if (keyCode === 32 && keySpace) {
            soundManager.play('menuSelect');
            
            if (selected === 0) {
                menu = false;
                first = true;
                if (!paused || savedVelocity.mag() === 0) {
                    velocity.x = random(2, 4) * (random() > 0.5 ? 1 : -1);
                    velocity.y = -random(6, 8);
                } else {
                    velocity.set(savedVelocity.x, savedVelocity.y);
                    paused = false;
                }
            } else if (selected === 1) {
                menu = false;
                skin = true;
                selected = 0;
            } else if (selected === 2) {
                menu = false;
            }
            keySpace = false;
            return false;
        }
    }
    // Skin selection navigation
    else if (skin) {
        if (keyCode === UP_ARROW || key === 'W' || key === 'w') {
            soundManager.play('menuNav');
            selected--;
            if (selected < 0) selected = menuSkin.length - 1;
        } else if (keyCode === DOWN_ARROW || key === 'S' || key === 's') {
            soundManager.play('menuNav');
            selected++;
            if (selected >= menuSkin.length) selected = 0;
        } else if (keyCode === 32 && keySpace) {
            soundManager.play('menuSelect');
            
            if (selected === 0) {
                skin = false;
                ballSkin = true;
                selected = 0;
            } else if (selected === 1) {
                skin = false;
                paddleSkin = true;
                selected = 0;
            } else if (selected === 2) {
                skin = false;
                brickSkin = true;
                selected = 0;
            }
            keySpace = false;
            return false;
        }
    }
    // Skin type selection
    else if (ballSkin || paddleSkin || brickSkin) {
        let arrayLength;
        if (ballSkin) arrayLength = Ballskins.length;
        else if (paddleSkin) arrayLength = Paddleskins.length;
        else arrayLength = Brickskins.length;
        
        if (keyCode === UP_ARROW || key === 'W' || key === 'w') {
            soundManager.play('menuNav');
            selected--;
            if (selected < 0) selected = arrayLength - 1;
        } else if (keyCode === DOWN_ARROW || key === 'S' || key === 's') {
            soundManager.play('menuNav');
            selected++;
            if (selected >= arrayLength) selected = 0;
        } else if (keyCode === 32 && keySpace) {
            soundManager.play('menuSelect');
            
            let pointNeeded = selected === 1 ? 500 : selected === 2 ? 1000 : 0;
            
            if (highskor >= pointNeeded || pointNeeded === 0) {
                if (ballSkin) BallTC = selected;
                if (paddleSkin) PaddleTC = selected;
                if (brickSkin) {
                    chooseBrick = selected;
                    // REINITIALIZE brick rows with new skin images
                    initializeBrickRows();
                }
                
                ballSkin = false;
                paddleSkin = false;
                brickSkin = false;
                skin = true;
                selected = 0;
            } else {
                soundManager.play('error');
                timer = millis();
            }
            keySpace = false;
            return false;
        }
    }
    // In-game controls
    else {
        if ((key === 'r' || key === 'R') && gameOver) {
            restartGame();
        }
        
        if (keyCode === 32 && keySpace && !mulai) {
            soundManager.play('gameStart');
            mulai = true;
            if (paused && savedVelocity.mag() > 0) {
                velocity.set(savedVelocity.x, savedVelocity.y);
                paused = false;
            } else {
                velocity.x = random(2, 4) * (random() > 0.5 ? 1 : -1);
                let speedMultiplier = stageBack === 0 ? 1 : stageBack === 1 ? 0.6 : 0.5;
                velocity.y = -random(6, 8) * speedMultiplier;
            }
            keySpace = false;
            return false;
        }
        
        if (key === 'a' || key === 'A' || keyCode === LEFT_ARROW) keyA = true;
        if (key === 'd' || key === 'D' || keyCode === RIGHT_ARROW) keyD = true;
    }
    
    if (keyCode === 32) {
        return false;
    }
}

function keyReleased() {
    if (key === 'a' || key === 'A' || keyCode === LEFT_ARROW) keyA = false;
    if (key === 'd' || key === 'D' || keyCode === RIGHT_ARROW) keyD = false;
    if (keyCode === 32) keySpace = true;
    
    return false;
}

// ==================== UTILITY FUNCTIONS ====================
function toggleSound() {
    const enabled = soundManager.toggle();
    if (soundToggleBtn) {
        soundToggleBtn.textContent = enabled ? '🔊 Sound: ON' : '🔇 Sound: OFF';
    }
}

function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen().catch(err => {
            console.log(`Error attempting to enable fullscreen: ${err.message}`);
        });
        if (fullscreenBtn) fullscreenBtn.textContent = '⛶ Exit Fullscreen';
    } else {
        if (document.exitFullscreen) {
            document.exitFullscreen();
            if (fullscreenBtn) fullscreenBtn.textContent = '⛶ Fullscreen';
        }
    }
}

function poinCukup() {
    if ((ballSkin || paddleSkin || brickSkin) && millis() - timer < 3000) {
        let skinArray = ballSkin ? Ballskins : paddleSkin ? Paddleskins : Brickskins;
        if (!skinArray || skinArray.length === 0) return;
        
        let pointNeeded = selected === 1 ? 500 : selected === 2 ? 1000 : 0;
        
        if (highskor < pointNeeded && pointNeeded > 0) {
            fill(255, 0, 0);
            textSize(16);
            text("Skor tidak cukup!", width / 2 - 150, height / 2 + 150);
        } else if (pointNeeded > 0) {
            fill(0, 255, 0);
            textSize(14);
            text("Skin akan diterapkan \npada stage berikutnya\natau restart!", width / 2 - 150, height / 2 + 150);
        }
    }
}

function drawUI() {
    // Draw score and lives
    drawTextWithStroke("Skor: " + skor + "  Nyawa: " + nyawa, width / 2, 20, 0, 255, 3);
    
    // Draw start prompt when not in menu and not started
    if (!mulai && !gameOver && !menu && !skin && !ballSkin && !paddleSkin && !brickSkin) {
        drawTextWithStroke("Press SPACE to start", width / 2, height - 100, 0, 255, 3);
    }
    
    // Draw game over screen
    if (gameOver && !menu) {
        anim -= 10;
        animText -= 10;
        anim = max(anim, 0);
        animText = max(animText, 200);
        
        fill(0, anim / 600 * 200);
        noStroke();
        rect(0, anim, width, height + 7);
        
        if (animText <= 300) {
            fill(255, 0, 0);
            textSize(30);
            text("Game Over", width / 2, animText);
            textSize(18);
            text("Press 'R' to restart", width / 2, animText + 40);
            textSize(16);
            text("Skor: " + skor, width / 2, animText + 80);
            text("High Skor: " + highskor, width / 2, animText + 100);
        }
    }
}

function drawTextWithStroke(txt, x, y, strokeColor, fillColor, strokeW) {
    push();
    stroke(strokeColor);
    strokeWeight(strokeW);
    fill(strokeColor);
    
    for (let i = -1; i <= 1; i++) {
        for (let j = -1; j <= 1; j++) {
            if (i !== 0 || j !== 0) {
                text(txt, x + i, y + j);
            }
        }
    }
    
    noStroke();
    fill(fillColor);
    text(txt, x, y);
    pop();
}

function checkCheatCodes() {
    const cheats = {
        'health': () => { 
            nyawa += 100; 
            console.log("Cheat: +100 Health"); 
        },
        'killme': () => { 
            nyawa = 0; 
            gameOver = true; 
            console.log("Cheat: You died"); 
        },
        'mygo': () => { 
            skor += 100; 
            console.log("Cheat: +100 Score"); 
        },
        'bricked': () => { 
            for (let i = 0; i < brickRows; i++) {
                for (let j = 0; j < brickCols; j++) {
                    bricks[i][j] = false;
                }
            }
            console.log("Cheat: All bricks destroyed");
        }
    };
    
    for (const [code, action] of Object.entries(cheats)) {
        if (inputBuffer.endsWith(code)) {
            action();
            inputBuffer = "";
            break;
        }
    }
}

// ==================== RESTART GAME ====================
function restartGame() {
    skor = 0;
    stage = 1;
    nyawa = 3;
    ballLocation.x = paddleX + paddleWidth / 2;
    ballLocation.y = paddleY - 30;
    paddleX = width / 2 - paddleWidth / 2;
    gameOver = false;
    mulai = false;
    anim = 600;
    animText = 900;
    
    bricks = Array(brickRows).fill().map(() => Array(brickCols).fill(true));
    initializeBrickRows();
}

// ==================== WINDOW RESIZE ====================
function windowResized() {
    resizeCanvas(500, 600);
}