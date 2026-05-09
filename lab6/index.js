require("dotenv").config(); 
const { PrismaClient } = require("@prisma/client");
const { Pool } = require("pg");
const { PrismaPg } = require("@prisma/adapter-pg");

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
	throw new Error("Не знайдено DATABASE_URL у файлі .env");
}

const pool = new Pool({ connectionString });
const adapter = new PrismaPg(pool);

const prisma = new PrismaClient({ adapter });

async function main() {
	console.log("=== Початок перевірки схеми ===");

	const timestamp = Date.now();

	const playerWhite = await prisma.player.create({
		data: {
			username: `Magnus_${timestamp}`,
			email: `magnus_${timestamp}@chess.com`,
			password_hash: "secret_123",
			rating: 2882,
			avatar_url: "https://example.com/magnus.png", 
			is_active: true,
		},
	});

	const playerBlack = await prisma.player.create({
		data: {
			username: `Hikaru_${timestamp}`,
			email: `hikaru_${timestamp}@chess.com`,
			password_hash: "secret_456",
			rating: 2789,
			is_active: true,
		},
	});

	const timeControl = await prisma.time_control.create({
		data: {
			name: "Blitz 3+2",
			initial_time_sec: 180,
			increment_sec: 2,
		},
	});
	const newGame = await prisma.game.create({
		data: {
			white_player_id: playerWhite.id,
			black_player_id: playerBlack.id,
			time_control_id: timeControl.id,
			chat_message: {
				create: [
					{
						player_id: playerWhite.id,
						message: "Good luck, have fun!",
					},
					{
						player_id: playerBlack.id,
						message: "You too!",
					},
				],
			},
		},
		include: {
			chat_message: true, 
			time_control: true,
		},
	});

}

main()
	.catch((e) => {
		console.error("Помилка під час виконання запитів:", e);
		process.exit(1);
	})
	.finally(async () => {
		await prisma.$disconnect();
	});
