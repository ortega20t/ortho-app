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