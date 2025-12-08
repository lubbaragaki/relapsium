# check for cat and echo

version=$(odin version)
if [[ "$version" == *"odin version dev"* ]]; then
  echo "Odin compiler installed, compiling shortly..."
else
  echo "Please download the Odin compiler and install it in your PATH"
fi

mkdir build
cd build
odin build ../src -build-mode:exe -out:relapsium 

sudo cp relapsium /usr/bin/

echo "relapsium added to PATH."

mkdir ~/.relapsium

echo "Installation complete."
echo " "
echo " "
echo "Usage: "
echo " "
echo "relapsium <COMMAND> [ARGUMENT]"
echo "  "
echo "  "
echo "Commands: "
echo " "
echo "new:<name>   Creates a new habit called "  
echo " "
echo "relapse:<name> d    Adds a relapse after d number of dyas "  
echo " "
echo "stat:<name>   Display statistics of habit called name "
echo " "
