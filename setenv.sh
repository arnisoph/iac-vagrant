_setenv() {
  [[ -e ../.env ]] && source ../.env
  [[ -e .env ]] && source .env

  if [[ -n "$box_name" ]]; then
    export BOX_NAME=${box_name}
  else
    unset BOX_NAME
  fi

  if [[ -z "$box_base_path" ]]; then
    export BOX_BASE_PATH=${box_base_path}
  else
    export BOX_BASE_PATH=${box_base_path}
  fi

  if [[ -z "$formula_dir" ]]; then
    export FORMULA_DIR=TODO
  else
    export FORMULA_DIR=${formula_dir}
  fi

  #BOX_PRIV_KEY=../../vagrant-devenv/shared/keys/id_rsa \
}

if [[ ! -f Vagrantfile ]]; then
  echo "Not a vagrant dir, won't set any environment variables".
else
  _setenv
fi
