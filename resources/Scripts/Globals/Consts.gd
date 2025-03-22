extends Node

const TILE_SIZE_32 = Vector2(32, 32)
const TILE_SIZE_64 = Vector2(64, 64)

const TIER_COLORS = [
	'ffa214',
	'c42430',
	'0c0293',
	'622461',
]

const RESOURCES_ATLAS_TO_NAME = {
	Vector2(0, 1) : "minerio_de_cobre",
	Vector2(1, 1) : "minerio_de_ouro",
	Vector2(2, 1) : "minerio_de_ferro",
	Vector2(3, 1) : "minerio_de_zinco",
}
