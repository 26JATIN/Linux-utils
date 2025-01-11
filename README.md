# This Shell script allows you to extract text using screenshot in any linux desktop enviornment

## Here are few steps for different distribution to follow before using this script
### Download script
```
git clone https://github.com/26JATIN/Extract-text-using-screenshot-in-linux.git
mv Extract-text-using-screenshot-in-linux/Text_Extractor.sh ~/
```

### For Fedora based distribution

```
sudo dnf install gnome-screenshot
sudo dnf install xclip
sudo dnf install tesseract-ocr
sudo dnf install tesseract-ocr-eng
```


### For Ubuntu based distribution

```
sudo add-apt-repository ppa:alex-p/tesseract-ocr5
sudo apt-get update
sudo apt-get install tesseract-ocr
sudo apt-get install tesseract-ocr-eng
sudo apt-get install gnome-screenshot
sudo apt-get install xclip
```

### For Arch based distribution
```
sudo pacman -S gnome-screenshot
sudo pacman -S xclip
sudo pacman -S tesseract-ocr
sudo pacman -s tesseract-ocr-eng
```


# important note!
### How to run this bash script?

1.open terminal and type ./Text_Extractor.sh 

2.Select area you want to capture text from. 

3.Now assign a shortcut key ctrl+t and assign command ./Text_Extractor.sh , so that everytime when you press ctrl+t this script executes.
