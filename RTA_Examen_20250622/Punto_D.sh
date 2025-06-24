#!/bin/bash

REMOTE_USER="JValenciano"


IP_LOCAL=$(hostname -I | awk '{print $1}')

if id "$REMOTE_USER" &>/dev/null; then
    echo "Usuario $REMOTE_USER ya existe."
else
    echo "Creando usuario $REMOTE_USER"
    sudo adduser --disabled-password --gecos '' $REMOTE_USER
fi

if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    echo "Generando clave SSH"
    ssh-keygen -t rsa -b 2048 -N '' -f $HOME/.ssh/id_rsa
else
    echo "Clave SSH ya generada"
fi

ssh-copy-id $REMOTE_USER@127.0.0.1

ssh -o BatchMode=yes $REMOTE_USER@127.0.0.1 echo 'Conexión SSH sin password funciona'

BASE_DIR=RTA_Examen_20240619

mkdir -p $BASE_DIR/roles/2PRecuperatorio/tasks
mkdir -p $BASE_DIR/roles/Alta_Usuarios_valenciano/tasks
mkdir -p $BASE_DIR/roles/Sudoers_valenciano/tasks
mkdir -p $BASE_DIR/roles/Instala-tools_valenciano/tasks

cat > $BASE_DIR/playbook.yml <<'EOF'
---
- name: Playbook Examen
  hosts: all
  become: true
  roles:
    - 2PRecuperatorio
    - Alta_Usuarios_valenciano
    - Sudoers_valenciano
    - Instala-tools_valenciano
EOF

cat > $BASE_DIR/roles/2PRecuperatorio/tasks/main.yml <<'EOF'
---
- name: Crear directorio /tmp/alumno
  file:
    path: /tmp/alumno
    state: directory

- name: Generar datos del alumno
  copy:
    dest: /tmp/alumno/datos.txt
    content: |
      Nombre: Juan
      Apellido: Valenciano
      División: 318
      Fecha: {{ ansible_date_time.date }}
      Distribución: {{ ansible_distribution }}
      Cores: {{ ansible_processor_vcpus }}
EOF

cat > $BASE_DIR/roles/Alta_Usuarios_valenciano/tasks/main.yml <<'EOF'
---
- name: Crear grupos
  group:
    name: "{{ item }}"
    state: present
  loop:
    - GProfesores
    - GAlumnos

- name: Crear usuarios
  user:
    name: "{{ item.name }}"
    groups: "{{ item.group }}"
    append: yes
  loop:
    - { name: "Profesor", group: "GProfesores" }
    - { name: "alumno", group: "GAlumnos" }
EOF

cat > $BASE_DIR/roles/Sudoers_valenciano/tasks/main.yml <<'EOF'
---
- name: Dar sudo sin password a GProfesores
  copy:
    dest: /etc/sudoers.d/gprofesores
    content: "%GProfesores ALL=(ALL) NOPASSWD: ALL\n"
    mode: '0440'
EOF

cat > $BASE_DIR/roles/Instala-tools_valenciano/tasks/main.yml <<'EOF'
---
- name: Instalar paquetes
  apt:
    name:
      - htop
      - tmux
      - tree
      - speedtest-cli
    state: present
    update_cache: yes
EOF

ansible-playbook -i $IP_LOCAL, RTA_Examen_20240619/playbook.yml -u $REMOTE_USER
