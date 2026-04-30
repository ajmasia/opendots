# SPDX-License-Identifier: GPL-3.0-or-later

# Mensajes de error
MSG_BASH_TOO_OLD="dots requiere bash >= 4 (encontrado: %s). Por favor, actualiza."
MSG_UNKNOWN_FLAG="Flag desconocido: %s"
MSG_UNKNOWN_SUBCMD="Subcomando desconocido: '%s'"
MSG_SUGGEST_SUBCMD="  ¿Quisiste decir: %s?"
MSG_USAGE_HINT="Ejecuta 'dots --help' para ver la ayuda."
MSG_NOT_IMPLEMENTED="%s: aún no implementado."

# Ayuda — etiquetas estructurales
MSG_HELP_USAGE="Uso: dots [opciones] <subcomando> [args]"
MSG_HELP_SUBCMDS_HEADER="Subcomandos:"
MSG_HELP_OPTS_HEADER="Opciones globales:"
MSG_VERSION_LINE="v%s (GPL-3.0-or-later)"

# Descripciones breves de subcomandos
MSG_SUBCMD_INSTALL="Enlaza paquetes de tu repositorio de dotfiles"
MSG_SUBCMD_REMOVE="Desenlaza paquetes"
MSG_SUBCMD_ADOPT="Adopta un archivo existente en un paquete"
MSG_SUBCMD_LIST="Lista los paquetes disponibles"
MSG_SUBCMD_STATUS="Muestra el estado de stow"
MSG_SUBCMD_DOCTOR="Verifica la salud del sistema"
MSG_SUBCMD_HELP="Muestra este mensaje de ayuda"

# Descripciones de opciones
MSG_OPT_HELP="Muestra este mensaje de ayuda"
MSG_OPT_VERSION="Muestra la versión"
MSG_OPT_NO_COLOR="Deshabilita los colores"
MSG_OPT_DRY_RUN="Simula sin aplicar cambios"
MSG_OPT_PROFILE="Usa el perfil indicado"
MSG_OPT_DIR="Directorio de dotfiles (defecto: ~/dotfiles)"
MSG_OPT_YES="Confirma automáticamente las preguntas"
MSG_OPT_LANG="Cambia el idioma (en, es)"

# Líneas de uso por subcomando
MSG_HELP_INSTALL="Uso: dots install <paquete...>"
MSG_HELP_REMOVE="Uso: dots remove <paquete...>"
MSG_HELP_ADOPT="Uso: dots adopt <paquete>"
MSG_HELP_LIST="Uso: dots list"
MSG_HELP_STATUS="Uso: dots status"
MSG_HELP_DOCTOR="Uso: dots doctor"

# repo.sh
MSG_REPO_NOT_FOUND="Directorio de dotfiles no encontrado: %s"
MSG_REPO_HINT="Créalo, define DOTS_DIR, o usa --dir <ruta>."

# cmd_install.sh
MSG_PKG_NOT_FOUND="Paquete no encontrado: %s"
MSG_INSTALL_CONFLICT="Conflicto: el archivo destino ya existe (no es un enlace):"
MSG_INSTALL_ADOPT_HINT="Ejecuta 'dots adopt <paquete>' para adoptar los archivos existentes."
MSG_INSTALL_OK="Instalado: %s"

# cmd_remove.sh
MSG_REMOVE_OK="Eliminado: %s"

# cmd_adopt.sh
MSG_ADOPT_PREVIEW="Los siguientes archivos se moverán al paquete:"
MSG_ADOPT_CONFIRM="¿Continuar? [s/N] "
MSG_ADOPT_ABORTED="Cancelado."
MSG_ADOPT_NOTHING="Nada que adoptar para el paquete: %s"
MSG_ADOPT_OK="Adoptado: %s"

# cmd_list.sh
MSG_LIST_EMPTY="No se encontraron paquetes en %s"

# cmd_status.sh
MSG_STATUS_DOTFILES="Dotfiles: %s"
MSG_STATUS_LINKED="Paquetes enlazados (%s):"
MSG_STATUS_CONFLICTS="Conflictos (%s):"
MSG_STATUS_NONE="No hay paquetes enlazados."

# cmd_doctor.sh
MSG_DOCTOR_OK="Todo está en orden."
MSG_DOCTOR_ISSUES="%s problema(s) encontrado(s)."
MSG_DOCTOR_STOW_MISSING="stow no está instalado."
MSG_DOCTOR_BASH_OLD="bash < 4.0 detectado (encontrado: %s)"
MSG_DOCTOR_STOW_OLD="stow < 2.3.1 detectado (encontrado: %s)"
MSG_DOCTOR_BROKEN_LINK="Enlace roto: %s"
