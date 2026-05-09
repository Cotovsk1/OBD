-- CreateTable
CREATE TABLE "friendship" (
    "user1_id" INTEGER NOT NULL,
    "user2_id" INTEGER NOT NULL,
    "status" VARCHAR(20) DEFAULT 'pending',
    "created_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "friendship_pkey" PRIMARY KEY ("user1_id","user2_id")
);

-- CreateTable
CREATE TABLE "game" (
    "id" SERIAL NOT NULL,
    "white_player_id" INTEGER NOT NULL,
    "black_player_id" INTEGER,
    "time_control_id" INTEGER NOT NULL,
    "tournament_id" INTEGER,
    "played_at" TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    "result_id" INTEGER,

    CONSTRAINT "game_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "game_result" (
    "id" SERIAL NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "description" VARCHAR(50) NOT NULL,

    CONSTRAINT "game_result_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "move" (
    "game_id" INTEGER NOT NULL,
    "move_number" INTEGER NOT NULL,
    "notation" VARCHAR(10) NOT NULL,

    CONSTRAINT "move_pkey" PRIMARY KEY ("game_id","move_number")
);

-- CreateTable
CREATE TABLE "player" (
    "id" SERIAL NOT NULL,
    "username" VARCHAR(50) NOT NULL,
    "email" VARCHAR(100) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "rating" INTEGER NOT NULL DEFAULT 1200,

    CONSTRAINT "player_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "time_control" (
    "id" SERIAL NOT NULL,
    "name" VARCHAR(50) NOT NULL,
    "initial_time_sec" INTEGER NOT NULL,
    "increment_sec" INTEGER NOT NULL,

    CONSTRAINT "time_control_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tournament" (
    "id" SERIAL NOT NULL,
    "title" VARCHAR(100) NOT NULL,
    "start_date" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "tournament_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "game_result_code_key" ON "game_result"("code");

-- CreateIndex
CREATE UNIQUE INDEX "player_username_key" ON "player"("username");

-- CreateIndex
CREATE UNIQUE INDEX "player_email_key" ON "player"("email");

-- AddForeignKey
ALTER TABLE "friendship" ADD CONSTRAINT "friendship_user1_id_fkey" FOREIGN KEY ("user1_id") REFERENCES "player"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "friendship" ADD CONSTRAINT "friendship_user2_id_fkey" FOREIGN KEY ("user2_id") REFERENCES "player"("id") ON DELETE CASCADE ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "game" ADD CONSTRAINT "fk_game_result" FOREIGN KEY ("result_id") REFERENCES "game_result"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "game" ADD CONSTRAINT "game_black_player_id_fkey" FOREIGN KEY ("black_player_id") REFERENCES "player"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "game" ADD CONSTRAINT "game_time_control_id_fkey" FOREIGN KEY ("time_control_id") REFERENCES "time_control"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "game" ADD CONSTRAINT "game_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournament"("id") ON DELETE SET NULL ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "game" ADD CONSTRAINT "game_white_player_id_fkey" FOREIGN KEY ("white_player_id") REFERENCES "player"("id") ON DELETE RESTRICT ON UPDATE NO ACTION;

-- AddForeignKey
ALTER TABLE "move" ADD CONSTRAINT "move_game_id_fkey" FOREIGN KEY ("game_id") REFERENCES "game"("id") ON DELETE CASCADE ON UPDATE NO ACTION;
