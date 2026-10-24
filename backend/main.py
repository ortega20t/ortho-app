import random
from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

BASE = Path(__file__).parent
STATIC = BASE / "static"
STATIC.mkdir(exist_ok=True)

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"],
                   allow_methods=["*"], allow_headers=["*"])
app.mount("/static", StaticFiles(directory=STATIC), name="static")

INSTRUMENTOS = [
    {"id": 1, "nombre": "Pinza Kocher", "categoria": "Hemostática",
     "imagen": "kocher.jpg", "uso": "Hemostasia y sujeción de tejidos"},
    {"id": 2, "nombre": "Pinza de reducción ósea (Weber)", "categoria": "Agarre óseo",
     "imagen": "weber.jpg", "uso": "Sujetar y reducir fragmentos óseos durante una fractura"},
    {"id": 3, "nombre": "Pinza de Lowman", "categoria": "Agarre óseo",
     "imagen": "lowman.jpg", "uso": "Sujetar hueso y mantener placas en posición mientras se fijan"},
    {"id": 4, "nombre": "Pinza de Verbrugge", "categoria": "Agarre óseo",
     "imagen": "verbrugge.jpg", "uso": "Agarrar y manipular fragmentos óseos"},
    {"id": 5, "nombre": "Pinza gubia (Luer)", "categoria": "Corte óseo",
     "imagen": "gubia_luer.jpg", "uso": "Cortar y retirar pequeños fragmentos de hueso"},
    {"id": 6, "nombre": "Separador de Hohmann", "categoria": "Separador",
     "imagen": "hohmann.jpg", "uso": "Retraer tejidos blandos y proteger estructuras alrededor del hueso"},
    {"id": 7, "nombre": "Separador de Bennett", "categoria": "Separador",
     "imagen": "bennett.jpg", "uso": "Retraer músculo y tejidos blandos para exponer el hueso"},
    {"id": 8, "nombre": "Separador de Farabeuf", "categoria": "Separador",
     "imagen": "farabeuf.jpg", "uso": "Retraer tejidos superficiales en la abertura de la incisión"},
    {"id": 9, "nombre": "Osteótomo", "categoria": "Corte óseo",
     "imagen": "osteotomo.jpg", "uso": "Cortar o remodelar hueso, se golpea con el mazo"},
    {"id": 10, "nombre": "Elevador de periostio", "categoria": "Disección",
     "imagen": "periostotomo.jpg", "uso": "Despegar el periostio del hueso"},
    {"id": 11, "nombre": "Cureta de Volkmann", "categoria": "Legrado",
     "imagen": "volkmann.jpg", "uso": "Raspar hueso o tejido, por ejemplo para limpiar un foco de fractura"},
]

def tiene_foto(i):
    return (STATIC / i["imagen"]).exists()


def con_imagen(i):
    return {**i, "imagen_url": f"/static/{i['imagen']}" if tiene_foto(i) else None}


@app.get("/instrumentos")
def listar():
    return [con_imagen(i) for i in INSTRUMENTOS]


@app.get("/quiz")
def quiz(modo: str = "uso"):
    if modo == "imagen":
        con_foto = [i for i in INSTRUMENTOS if tiene_foto(i)]
        if not con_foto:
            raise HTTPException(status_code=400, detail="Aún no hay fotos en static/")
        correcta = random.choice(con_foto)
        pregunta = "¿Cómo se llama este instrumento?"
    else:
        correcta = random.choice(INSTRUMENTOS)
        pregunta = f"¿Qué instrumento se usa para esto?\n\n{correcta['uso']}"

    otras = [i for i in INSTRUMENTOS if i["id"] != correcta["id"]]
    opciones = random.sample(otras, 3) + [correcta]
    random.shuffle(opciones)
    return {
        "pregunta": pregunta,
        "imagen_url": con_imagen(correcta)["imagen_url"] if modo == "imagen" else None,
        "opciones": [{"id": o["id"], "nombre": o["nombre"]} for o in opciones],
        "correcta": correcta["id"],
        "categoria": correcta["categoria"],
    }


def _s(id, num, nombre, cantidad, x, y):
    return {"id": id, "num": num, "nombre": nombre,
            "cantidad": cantidad, "x": x, "y": y}


MESAS = [
    {
        "id": "mayo",
        "nombre": "Mesa de mayo",
        "aspecto": 1.47,
        "slots": [
            _s(1, "1", "Mango de bisturí N.º 4", 1, 0.04, 0.43),
            _s(2, "2", "Tijera de Metzenbaum", 1, 0.135, 0.43),
            _s(3, "3", "Tijera de Mayo", 1, 0.258, 0.43),
            _s(4, "4", "Disector", 1, 0.375, 0.43),
            _s(5, "5", "Elevador de periostio", 1, 0.49, 0.43),
            _s(6, "6", "Cureta", 1, 0.613, 0.43),
            _s(7, "7", "Separador de Volkmann", 2, 0.695, 0.43),
            _s(8, "8", "Separador de Farabeuf", 2, 0.777, 0.43),
            _s(9, "9", "Kelly curvas", 6, 0.90, 0.185),
            _s(10, "10", "Rochester curvas", 4, 0.90, 0.513),
            _s(11, "11", "Allis", 4, 0.90, 0.80),
            _s(12, "12", "Disección con garra", 2, 0.237, 0.853),
            _s(13, "13", "Disección sin garra", 1, 0.472, 0.853),
        ],
    },
    {
        "id": "reserva",
        "nombre": "Mesa de reserva",
        "aspecto": 1.6,
        "slots": [
            _s(101, "1", "Bandeja del instrumental con riñonera y copa", 1, 0.066, 0.47),
            _s(102, "2", "Separador de Farabeuf (rama larga)", 1, 0.115, 0.62),
            _s(103, "3", "Separador de Hohmann", 1, 0.186, 0.62),
            _s(104, "4", "Separador de Bennett", 1, 0.245, 0.62),
            _s(105, "5", "Pinzas de huesos", 1, 0.293, 0.62),
            _s(106, "6", "Clamps de Lowman", 1, 0.341, 0.62),
            _s(107, "7", "Gancho de Lambotte", 1, 0.40, 0.62),
            _s(108, "8", "Porta agujas", 1, 0.356, 0.226),
            _s(109, "8", "Porta agujas", 1, 0.527, 0.234),
            _s(110, "9", "Martillo", 1, 0.72, 0.19),
            _s(111, "10", "Cinceles y osteótomos", 1, 0.564, 0.587),
            _s(112, "11", "Perforador y brocas", 1, 0.648, 0.587),
            _s(113, "12", "Gubias", 1, 0.72, 0.587),
            _s(114, "13", "Material de osteosíntesis", 1, 0.793, 0.587),
            _s(115, "14", "Instrumental accesorio", 1, 0.873, 0.31),
            _s(116, "15", "Paquete de ropa", 1, 0.95, 0.53),
            _s(117, "16", "Pinzas de campo", 1, 0.875, 0.116),
        ],
    },
]


@app.get("/mesas")
def mesas():
    return MESAS