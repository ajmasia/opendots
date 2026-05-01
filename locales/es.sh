# SPDX-License-Identifier: GPL-3.0-or-later

# Mensajes de error
MSG_BASH_TOO_OLD="dfy requiere bash >= 4 (encontrado: %s). Por favor, actualiza."
MSG_UNKNOWN_FLAG="Flag desconocido: %s"
MSG_UNKNOWN_SUBCMD="Subcomando desconocido: '%s'"
MSG_SUGGEST_SUBCMD="  ¿Quisiste decir: %s?"
MSG_USAGE_HINT="Ejecuta 'dfy --help' para ver la ayuda."
MSG_NOT_IMPLEMENTED="%s: aún no implementado."

# Ayuda — etiquetas estructurales
MSG_HELP_USAGE="Uso: dfy [opciones] <subcomando> [args]"
MSG_HELP_SUBCMDS_HEADER="Subcomandos:"
MSG_HELP_OPTS_HEADER="Opciones globales:"

# Descripciones breves de subcomandos
MSG_SUBCMD_APPLY="Aplica paquetes de tu repositorio de dotfiles"
MSG_SUBCMD_REMOVE="Desenlaza paquetes"
MSG_SUBCMD_ADOPT="Adopta un archivo existente en un paquete"
MSG_SUBCMD_LIST="Lista los paquetes disponibles"
MSG_SUBCMD_STATUS="Muestra el estado de stow"
MSG_SUBCMD_DOCTOR="Verifica la salud del sistema"
MSG_SUBCMD_UPDATE="Actualiza Dotlify a la última versión"
MSG_SUBCMD_UNINSTALL="Elimina Dotlify de este sistema"
MSG_SUBCMD_HELP="Muestra este mensaje de ayuda"

# Descripciones de opciones
MSG_OPT_HELP="Muestra este mensaje de ayuda"
MSG_OPT_VERSION="Muestra la versión"
MSG_OPT_NO_COLOR="Deshabilita los colores"
MSG_OPT_DRY_RUN="Simula sin aplicar cambios"
MSG_OPT_PROFILE="Usa el perfil indicado"
MSG_OPT_DIR="Directorio de dotfiles (defecto: ~/.dotfiles)"
MSG_OPT_YES="Confirma automáticamente las preguntas"
MSG_OPT_LANG="Cambia el idioma (en, es)"

# Líneas de uso por subcomando
MSG_HELP_APPLY="Uso: dfy apply <paquete...>"
MSG_HELP_REMOVE="Uso: dfy remove <paquete...>"
MSG_HELP_ADOPT="Uso: dfy adopt <paquete>"
MSG_HELP_LIST="Uso: dfy list"
MSG_HELP_STATUS="Uso: dfy status"
MSG_HELP_DOCTOR="Uso: dfy doctor"
MSG_HELP_UPDATE="Uso: dfy update"
MSG_HELP_UNINSTALL="Uso: dfy uninstall"

# repo.sh
MSG_REPO_NOT_FOUND="Directorio de dotfiles no encontrado: %s"
MSG_REPO_HINT="Créalo, define DFY_DIR, o usa --dir <ruta>."

# cmd_apply.sh
MSG_PKG_NOT_FOUND="Paquete no encontrado: %s"
MSG_APPLY_CONFLICT="Conflicto: el archivo destino ya existe (no es un enlace):"
MSG_APPLY_ADOPT_HINT="Ejecuta 'dfy adopt <paquete>' para adoptar los archivos existentes."
MSG_APPLY_OK="Aplicado: %s"

# cmd_unlink.sh
MSG_UNLINK_OK="Desenlazado: %s"
MSG_UNLINK_REPO_HINT="Los archivos del paquete permanecen en tu repositorio de dotfiles."
MSG_SUBCMD_UNLINK="Elimina los enlaces de los paquetes"
MSG_HELP_UNLINK="Uso: dfy unlink <paquete...>"

# cmd_adopt.sh
MSG_ADOPT_PREVIEW="Los siguientes archivos se moverán al paquete:"
MSG_ADOPT_CONFIRM="¿Continuar? [s/N] "
MSG_ADOPT_ABORTED="Cancelado."
MSG_ADOPT_NOTHING="Nada que adoptar para el paquete: %s"
MSG_ADOPT_OK="Adoptado: %s"

# cmd_list.sh
MSG_LIST_EMPTY="No se encontraron paquetes en %s"
MSG_LIST_NO_README="sin readme"

# cmd_info.sh
MSG_INFO_NO_README="No hay README para %s"
MSG_SUBCMD_INFO="Muestra el README de un paquete"
MSG_HELP_INFO="Uso: dfy info <paquete>"

# cmd_create.sh
MSG_CREATE_EXISTS="El paquete ya existe y tiene README: %s"
MSG_CREATE_ASK_DESC="Descripción (opcional, Enter para omitir): "
MSG_CREATE_DONE="Paquete creado: %s"
MSG_CREATE_README_DONE="README creado para %s"
MSG_CREATE_HINT="Añade tus archivos de configuración en %s y ejecuta: dfy apply %s"
MSG_SUBCMD_CREATE="Crea un nuevo paquete"
MSG_HELP_CREATE="Uso: dfy create <paquete>"

# cmd_status.sh
MSG_STATUS_DOTFILES="Dotfiles: %s"
MSG_STATUS_LINKED="Paquetes enlazados (%s):"
MSG_STATUS_CONFLICTS="Conflictos (%s):"
MSG_STATUS_NOT_LINKED="No enlazados (%s):"
MSG_STATUS_NONE="No se encontraron paquetes."
MSG_STATUS_CONFLICT_HINT="el destino ya existe, ejecuta: dfy adopt"

# profile.sh
MSG_PROFILE_NOT_FOUND="Perfil no encontrado: %s"
MSG_PROFILE_AVAILABLE="Perfiles disponibles: %s"
MSG_PROFILE_NONE="No hay perfiles definidos."
MSG_STATUS_PROFILE="Perfil activo: %s"
MSG_STATUS_NO_PROFILE="(sin perfil activo)"

# cmd_doctor.sh
MSG_DOCTOR_OK="Todo está en orden."
MSG_DOCTOR_ISSUES="%s problema(s) encontrado(s)."
MSG_DOCTOR_STOW_MISSING="stow no está instalado."
MSG_DOCTOR_BASH_OLD="bash < 4.0 detectado (encontrado: %s)"
MSG_DOCTOR_STOW_OLD="stow < 2.3.1 detectado (encontrado: %s)"
MSG_DOCTOR_BROKEN_LINK="Enlace roto: %s"

# cmd_update.sh
MSG_UPDATE_PULLING="Descargando últimos cambios..."
MSG_UPDATE_COMP="Actualizando completado de shell..."
MSG_UPDATE_OK="Dotlify actualizado correctamente."
MSG_UPDATE_NOT_GIT="No es un repositorio git, no se puede actualizar: %s"

# cmd_uninstall.sh
MSG_UNINSTALL_CONFIG="¿Eliminar directorio de configuración %s? [s/N] "
MSG_UNINSTALL_CONFIG_KEPT="Conservado: %s"
MSG_UNINSTALL_CLONE="¿Eliminar directorio del clon %s? [s/N] "
MSG_UNINSTALL_OK="Dotlify desinstalado."
