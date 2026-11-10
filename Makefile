# Blog «Corriente» — material didáctico del curso Lidr AI4Devs.
# API en 3401, web en 5401. No se usan 3333 ni 5173 a propósito.
#
# Versión para Windows nativo: cada línea de receta se ejecuta en Windows PowerShell.
# Necesita GNU Make para Windows (p. ej. `winget install GnuWin32.Make` o `choco install make`).
# La versión para Linux/macOS (sh) está en Makefile.linux: `make -f Makefile.linux <objetivo>`.
#
# Notas para quien edite este archivo:
#   - Make expande $(VAR); para que una variable llegue a PowerShell hay que escribir $$var.
#   - PowerShell 5.1 no tiene `&&` ni `||`: se encadena con `;` y se comprueba $$LASTEXITCODE.
#   - Cada línea de receta es un proceso PowerShell independiente (no se conserva el `cd`).
#   - make pasa la receta a PowerShell en la página de códigos ANSI, no en UTF-8: los textos
#     que se imprimen van sin tildes ni eñes para que no salgan como "Ã±".

SHELL := powershell.exe
.SHELLFLAGS := -NoProfile -ExecutionPolicy Bypass -Command

PUERTO_API ?= 3401
PUERTO_WEB ?= 5401

URL_FUGA := http://localhost:$(PUERTO_API)/posts/diez-tendencias-de-diseno-que-pueden-cambiar-la-web-moderna

.DEFAULT_GOAL := ayuda

.PHONY: ayuda setup db api web test test-coverage fuga build limpiar

ayuda:
	@Write-Host ''
	@Write-Host '  make setup          instala dependencias y prepara backend/.env'
	@Write-Host '  make db             recrea la base SQLite y la vuelve a sembrar'
	@Write-Host '  make api            arranca la API en http://localhost:$(PUERTO_API)'
	@Write-Host '  make web            arranca la web en http://localhost:$(PUERTO_WEB)'
	@Write-Host '  make test           corre la suite (la que hay: un test)'
	@Write-Host '  make test-coverage  corre la suite y mide cobertura con c8'
	@Write-Host '  make fuga           ensena los correos que salen en la respuesta publica'
	@Write-Host '  make build          compila el frontend'
	@Write-Host '  make limpiar        borra la base de datos y la cobertura'
	@Write-Host ''

setup:
	npm install --prefix backend; exit $$LASTEXITCODE
	npm install --prefix frontend; exit $$LASTEXITCODE
	@if (-not (Test-Path 'backend/.env')) { Copy-Item 'backend/.env.example' 'backend/.env'; Set-Location backend; node ace generate:key; exit $$LASTEXITCODE }
	@Write-Host 'Listo. Ahora: make db'

db:
	Set-Location backend; node ace migration:fresh; if ($$LASTEXITCODE -ne 0) { exit $$LASTEXITCODE }; node ace db:seed; exit $$LASTEXITCODE

api:
	Set-Location backend; node ace serve; exit $$LASTEXITCODE

web:
	Set-Location frontend; npm run dev; exit $$LASTEXITCODE

test:
	npm test --prefix backend; exit $$LASTEXITCODE

test-coverage:
	npm run test:coverage --prefix backend; exit $$LASTEXITCODE

# Enseña el dato personal saliendo por la respuesta pública. Falla RUIDOSAMENTE si la
# API no está levantada o la base no está sembrada: un vacío silencioso en mitad de una
# demo es indistinguible de "no hay fuga".
fuga:
	@try { Invoke-WebRequest -UseBasicParsing -TimeoutSec 3 -Uri 'http://localhost:$(PUERTO_API)/' | Out-Null } catch { if ($$null -eq $$_.Exception.Response) { Write-Host 'Nada escuchando en el $(PUERTO_API). Levanta la API en otra terminal: make api'; exit 1 } }
	@try { $$cuerpo = (Invoke-WebRequest -UseBasicParsing -TimeoutSec 5 -Uri '$(URL_FUGA)').Content } catch { $$cuerpo = '' }; $$correos = [regex]::Matches($$cuerpo, '"autor_email":"[^"]*"') | ForEach-Object { $$_.Value }; if (-not $$correos) { Write-Host 'La API responde pero no sale ningun correo. Has sembrado la base? make db'; exit 1 }; $$correos

build:
	npm run build --prefix frontend; exit $$LASTEXITCODE

limpiar:
	Remove-Item -Force -ErrorAction SilentlyContinue 'backend/tmp/db.sqlite3'
	Remove-Item -Recurse -Force -ErrorAction SilentlyContinue 'backend/coverage', 'frontend/dist'
