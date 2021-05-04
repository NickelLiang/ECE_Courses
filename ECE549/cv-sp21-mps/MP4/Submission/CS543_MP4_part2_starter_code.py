# -*- coding: utf-8 -*-
"""Copy_of_CS543_MP4_part2_starter_code-2.ipynb

Automatically generated by Colaboratory.

Original file is located at
    https://colab.research.google.com/drive/1DdfBW3SiX1L1_TpoChxhj3zEQRwPnSmy
"""

# Mounting your Google Drive is optional, and you could also simply copy and
# upload the data to your colab instance. This manula upload is also easy to do, 
# but you will have to figure out how to do it.
from google.colab import drive
drive.mount('/content/gdrive/')

import os
if not os.path.exists("/content/gdrive/My Drive/Colab Notebooks/CS_543_MP4"):
    os.makedirs("/content/gdrive/My Drive/Colab Notebooks/CS_543_MP4")
os.chdir("/content/gdrive/My Drive/Colab Notebooks/CS_543_MP4")

# Commented out IPython magic to ensure Python compatibility.
# download dataset
!wget https://drive.switch.ch/index.php/s/UG0ZlZXY47LKSaW/download
!unzip download
!rm download
# %cd data
!unzip -qqo albertville_rgb.zip
!unzip -qqo albertville_normal.zip
!unzip -qqo albertville_principal_curvature.zip
!unzip -qqo almena_rgb.zip
!unzip -qqo almena_normal.zip
!unzip -qqo almena_principal_curvature.zip
!rm albertville_rgb.zip albertville_normal.zip albertville_principal_curvature.zip almena_rgb.zip almena_normal.zip almena_principal_curvature.zip
# %cd ..
!ls

import glob
import os
import numpy as np
import random
import time
from tqdm.notebook import tqdm
import matplotlib.pyplot as plt

import cv2
from PIL import Image
import torch
import torch.nn as nn
import torch.nn.functional as F
from torch.utils import data
from torchvision import models
from torchvision.transforms import ToTensor, Normalize
import torch.optim as optim

# global variable
device = torch.device("cuda:0")

class NormalDataset(data.Dataset):
    """
    Data loader for the Suface Normal Dataset. If data loading is a bottleneck, 
    you may want to optimize this in for faster training. Possibilities include
    pre-loading all images and annotations into memory before training, so as 
    to limit delays due to disk reads.
    """
    def __init__(self, split="train", data_dir="./data"):
        assert(split in ["train", "val"])
        split2name = {
            "train": "almena",
            "val": "albertville",
        }
        self.img_dir = os.path.join(data_dir, split2name[split] + "_rgb", "rgb")
        self.gt_dir = os.path.join(data_dir, split2name[split] + "_normal", "normal")
        
        self.split = split
        self.filenames = [
            os.path.splitext(os.path.basename(l))[0] for l in glob.glob(self.img_dir + "/*.png")
        ]

    def __len__(self):
        return len(self.filenames)

    def __getitem__(self, index):
        filename = self.filenames[index]
        img = Image.open(os.path.join(self.img_dir, filename) + ".png")
        img = np.asarray(img).copy()
        gt = Image.open(os.path.join(self.gt_dir, filename.replace("_rgb", "_normal")) + ".png")
        gt = np.asarray(gt)

        # from rgb image to surface normal
        gt = gt.astype(np.float32) / 255
        gt = torch.Tensor(np.asarray(gt).copy()).permute((2, 0, 1))
        mask = self.build_mask(gt).to(torch.float)

        img = ToTensor()(img)
        img = Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])(img)

        # normalize gt
        gt = gt * 2 - 1
        
        return img.contiguous(), gt, mask.sum(dim=0) > 0

    @staticmethod
    def build_mask(target, val=0.502, tol=1e-3):
        target = target.unsqueeze(0)
        if target.shape[1] == 1:
            mask = ((target >= val - tol) & (target <= val + tol))
            mask = F.conv2d(mask.float(), torch.ones(1, 1, 5, 5, device=mask.device), padding=2) != 0
            return (~mask).expand_as(target).squeeze(0)

        mask1 = (target[:, 0, :, :] >= val - tol) & (target[:, 0, :, :] <= val + tol)
        mask2 = (target[:, 1, :, :] >= val - tol) & (target[:, 1, :, :] <= val + tol)
        mask3 = (target[:, 2, :, :] >= val - tol) & (target[:, 2, :, :] <= val + tol)
        mask = (mask1 & mask2 & mask3).unsqueeze(1)
        mask = F.conv2d(mask.float(), torch.ones(1, 1, 5, 5, device=mask.device), padding=2) != 0
        return (~mask).expand_as(target).squeeze(0)

class ASPP(nn.Module):
    def __init__(self, in_channels = 512, out_channels = 256):
        super(ASPP, self).__init__()

        self.relu = nn.ReLU(inplace=True)
        self.bn = nn.BatchNorm2d(out_channels)
        self.pool = nn.AdaptiveAvgPool2d(1)  

        self.conv1 = nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=1, bias=False)
        self.conv2 = nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=3, padding=6, dilation=6, bias=False)
        self.conv3 = nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=3, padding=12, dilation=12, bias=False)
        self.conv4 = nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=3, padding=18, dilation=18, bias=False)
        self.conv5 = nn.Conv2d(in_channels=in_channels, out_channels=out_channels, kernel_size=1, bias=False)

        self.conv = nn.Conv2d(in_channels=out_channels * 5, out_channels=out_channels, kernel_size=1, bias=False)

    def forward(self, x):
        x1 = self.conv1(x)
        x1 = self.bn(x1)
        x1 = self.relu(x1)

        x2 = self.conv2(x)
        x2 = self.bn(x2)
        x2 = self.relu(x2)

        x3 = self.conv3(x)
        x3 = self.bn(x3)
        x3 = self.relu(x3)

        x4 = self.conv4(x)
        x4 = self.bn(x4)
        x4 = self.relu(x4)

        x5 = self.pool(x)
        x5 = self.conv5(x5)
        x5 = self.bn(x5)
        x5 = self.relu(x5)
        x5 = F.interpolate(x5, size=tuple(x4.shape[-2:]), mode='bilinear', align_corners=True)

        x = torch.cat((x1, x2, x3, x4, x5), dim=1)
        x = self.conv(x)
        x = self.bn(x)
        x = self.relu(x)

        return x

class Decoder(nn.Module):
    def __init__(self, ll_channels = 64, out_channels = 3):
        super(Decoder, self).__init__()

        self.conv_ll = nn.Conv2d(in_channels=ll_channels, out_channels=48, kernel_size=1, bias=False)
        self.bn_ll = nn.BatchNorm2d(48)
        self.relu = nn.ReLU(inplace=True)

        # https://arxiv.org/pdf/1802.02611.pdf table 2
        self.conv = nn.Sequential(
            nn.Conv2d(in_channels=256+48, out_channels=256, kernel_size=3, stride=1, padding=1, bias=False),
            nn.BatchNorm2d(256),
            nn.ReLU(inplace=True),
            # nn.Dropout(0.5),
            nn.Conv2d(in_channels=256, out_channels=256, kernel_size=3, stride=1, padding=1, bias=False),
            nn.BatchNorm2d(256),
            nn.ReLU(inplace=True),
            nn.Dropout(0.1),
            nn.Conv2d(in_channels=256, out_channels=out_channels, kernel_size=1, stride=1))
        
    def forward(self, x, low_level):
        low_level = self.conv_ll(low_level)
        low_level = self.bn_ll(low_level)
        low_level = self.relu(low_level)

        x = F.interpolate(x, size=tuple(low_level.shape[-2:]), mode='bilinear', align_corners=True)
        x = torch.cat((x, low_level), dim = 1)
        x = self.conv(x)

        return x

# Grammer in this section is referenced from 
# https://github.com/mortezamg63/Accessing-and-modifying-different-layers-of-a-pretrained-model-in-pytorch
# https://towardsdatascience.com/using-predefined-and-pretrained-cnns-in-pytorch-e3447cbe9e3c
# Structure reference from
# https://arxiv.org/pdf/1802.02611.pdf : Deeplab V3+

class MyModel(nn.Module):
    def __init__(self): # feel free to modify input paramters
        super(MyModel, self).__init__()
        
        # Encoder
        resnet18 = models.resnet18(pretrained=True)
        self.resnet18_head = nn.Sequential(*(list(resnet18.children())[0:4]))
        self.resnet18_layer1 = nn.Sequential(*(list(resnet18.children())[4]))
        self.resnet18_layer2 = nn.Sequential(*(list(resnet18.children())[5]))
        self.resnet18_layer3 = nn.Sequential(*(list(resnet18.children())[6]))
        self.resnet18_layer4 = nn.Sequential(*(list(resnet18.children())[7]))

        # Atrous Spatial Pyramid Pooling
        self.aspp = ASPP(in_channels = 512, out_channels = 256)
        
        # Decoder
        self.decoder = Decoder(ll_channels = 64, out_channels = 3)

        # self.conv2 = nn.Conv2d(in_channels = 256, out_channels = 3, kernel_size = 1)

    def forward(self, x): # feel free to modify input paramters
        # Get input size for later use
        _, _, h, w = x.shape        # 3 * 512 * 512

        # Construct Resnet18 and save low level feature
        x = self.resnet18_head(x)   # 64 * 128 * 128
        x = self.resnet18_layer1(x) # 64 * 128 * 128
        low_level = x
        x = self.resnet18_layer2(x) # 128 * 64 * 64
        x = self.resnet18_layer3(x) # 256 * 32 * 32
        x = self.resnet18_layer4(x) # 512 * 16 * 16

        # Construct Atrous Spatial Pyramid Pooling
        x = self.aspp(x)            # 256 * 16 * 16

        # Construct Decoder
        x = self.decoder(x, low_level)  # 3 * 128 * 128

        # x = self.conv2(x)

        x = F.interpolate(x, size=(h, w), mode='bilinear', align_corners=True)
        x = F.normalize(x)

        return x

##########
#TODO: define your loss function here
##########
class MyCriterion(nn.Module):
    def __init__(self):
        super(Criterion, self).__init__()
        pass

    def forward(self, prediction, target, mask):
        pass

def simple_train(model, criterion, optimizer, train_dataloader, epoch, **kwargs):
    # Set the model to trainning mode
    model.train()
    
    running_loss = 0.0
    for i, data in enumerate(train_dataloader, 0):
        # get the inputs
        inputs, labels, bool_mask = data
        inputs = inputs.cuda()
        labels = labels.cuda()

        # zero the parameter gradients
        optimizer.zero_grad()

        # forward + backward + optimize
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        # print(loss.shape)
        loss.backward()
        optimizer.step()

        # print statistics
        running_loss += loss.item()

    # Normalizing the loss by the total number of train batches
    running_loss/=len(train_dataloader)
    print(len(train_dataloader))
    print('[%d] loss: %.3f' %
          (epoch + 1, running_loss))

def angle_error(prediction, target):
    prediction_error = torch.cosine_similarity(prediction, target)
    prediction_error = torch.clamp(prediction_error, min=-1.0, max=1.0)
    prediction_error = torch.acos(prediction_error) * 180.0 / np.pi
    return prediction_error

def simple_predict(split, model):
    model.eval()
    dataset = NormalDataset(split=split)
    dataloader = data.DataLoader(dataset, batch_size=1, shuffle=False, 
                                 num_workers=2, drop_last=False)
    gts, preds, losses = [], [], []
    total_normal_errors = None
    with torch.no_grad():
        for i, batch in enumerate(tqdm(dataloader)):
            img, gt, mask = batch
            img = img.to(device)
            gt = gt.to(device)
            mask = mask.to(device)

            pred = model(img)
            loss = (F.l1_loss(pred, gt, reduction="none") * mask).mean()

            gts.append((gt[0].permute((1, 2, 0)).cpu().numpy() + 1) / 2)
            preds.append((pred[0].permute((1, 2, 0)).cpu().numpy() + 1) / 2)
            losses.append(loss.item())

            angle_error_prediction = angle_error(pred, gt)
            angle_error_prediction = angle_error_prediction[mask > 0].view(-1)
            if total_normal_errors is None:
                total_normal_errors = angle_error_prediction.cpu().numpy()
            else:
                total_normal_errors = np.concatenate(
                    (total_normal_errors, angle_error_prediction.cpu().numpy())
                )

    return gts, preds, losses, total_normal_errors

model = MyModel().to(device)
print(model)

# criterion = MyCriterion().to(device)
# criterion = nn.CosineEmbeddingLoss()
criterion = nn.L1Loss()
# optimizer = optim.SGD(model.parameters(), lr=0.001, momentum=0.9, weight_decay=1e-4)
optimizer = optim.Adam(model.parameters(), lr=0.0001, weight_decay=1e-4)
train_dataset = NormalDataset(split='train')
train_dataloader = data.DataLoader(train_dataset, batch_size=8, 
                                    shuffle=True, num_workers=2, 
                                    drop_last=True)

# Reference from https://arxiv.org/pdf/1506.01186.pdf
# scheduler = optim.lr_scheduler.CyclicLR(optimizer, step_size_up=30, base_lr=0.001, max_lr=0.005, cycle_momentum=False)
scheduler = optim.lr_scheduler.CyclicLR(optimizer, step_size_up=30, base_lr=0.0001, max_lr=0.0019, cycle_momentum=False)

########################################################################
# TODO: Implement your training cycles, make sure you evaluate on validation 
# dataset and compute evaluation metrics every so often. 
# You may also want to save models that perform well.

num_epochs = 65
lr_over_epochs = []
val_loss_over_epochs = []
mean_error_over_epochs = []

for epoch in tqdm(range(num_epochs), total=num_epochs):
    simple_train(model, criterion, optimizer, train_dataloader, epoch)
    # consider reducing learning rate
    print('lr: ', scheduler.get_last_lr())
    lr_over_epochs.append(scheduler.get_last_lr())
    if (epoch % 1 == 0):
        val_gts, val_preds, val_losses, val_total_normal_errors = simple_predict('val', model)
        print("Validation loss (L1):", np.mean(val_losses))
        print("Validation metrics: Mean %.1f, Median %.1f, 11.25deg %.1f, 22.5deg %.1f, 30deg %.1f" % (
            np.average(val_total_normal_errors), np.median(val_total_normal_errors),
            np.sum(val_total_normal_errors < 11.25) / val_total_normal_errors.shape[0] * 100,
            np.sum(val_total_normal_errors < 22.5) / val_total_normal_errors.shape[0] * 100,
            np.sum(val_total_normal_errors < 30) / val_total_normal_errors.shape[0] * 100
        ))
        if (np.average(val_total_normal_errors) <= 30.5):
            torch.save(model, './model_'+str(epoch))
        val_loss_over_epochs.append(np.mean(val_losses))
        mean_error_over_epochs.append(np.average(val_total_normal_errors))
    scheduler.step()

# plt.ioff()
fig = plt.figure()

plt.subplot(3, 1, 1)
plt.ylabel('Mean Error')
plt.xlabel('Per 5 Epochs')
# plt.plot(np.arange(num_epochs), mean_error_over_epochs, 'k-')
plt.plot(mean_error_over_epochs, 'k-')
plt.title('Mean Error vs epochs')
# plt.xticks(np.arange(num_epochs, dtype=int))
plt.grid(True)

plt.subplot(3, 1, 2)
# plt.plot(np.arange(num_epochs), val_loss_over_epochs, 'b-')
plt.plot(val_loss_over_epochs, 'b-')
plt.ylabel('Val loss')
plt.xlabel('Per 5 Epochs')
# plt.xticks(np.arange(num_epochs, dtype=int))
plt.grid(True)

plt.subplot(3, 1, 3)
plt.plot(lr_over_epochs, mean_error_over_epochs, 'b-')
plt.ylabel('Val loss')
plt.xlabel('LR')
# plt.xticks(np.arange(num_epochs, dtype=int))
plt.grid(True)

plt.savefig("mp4_q2_plot.png")
# plt.close(fig)

# plt.ion()

# !ls
# torch.save(model, './model_'+str(epoch))
# !ls

# model = torch.load('./model_56')
# model

"""# You do not need to change anything below"""

########################################################################
# Evaluate your result, and report
# 1. Mean angular error
# 2. Median angular error
# 3. Accuracy at 11.25 degree
# 4. Accuracy at 22.5 degree
# 5. Accuracy at 30 degree
# using provided `simple_predict` function.

val_gts, val_preds, val_losses, val_total_normal_errors = simple_predict('val', model)
print("Validation loss (L1):", np.mean(val_losses))
print("Validation metrics: Mean %.1f, Median %.1f, 11.25deg %.1f, 22.5deg %.1f, 30deg %.1f" % (
    np.average(val_total_normal_errors), np.median(val_total_normal_errors),
    np.sum(val_total_normal_errors < 11.25) / val_total_normal_errors.shape[0] * 100,
    np.sum(val_total_normal_errors < 22.5) / val_total_normal_errors.shape[0] * 100,
    np.sum(val_total_normal_errors < 30) / val_total_normal_errors.shape[0] * 100
))

# vis validation
fig, axs = plt.subplots(ncols=5, nrows=2, figsize=(22, 7))
for idx, ax_i in enumerate(axs.T):
    ax = ax_i[0]
    ax.imshow(val_gts[idx])
    ax.axis('off')
    ax = ax_i[1]
    ax.imshow(val_preds[idx])
    ax.axis('off')
fig.tight_layout()
plt.savefig('vis_valset.pdf', format='pdf', bbox_inches='tight')

# Visualization
# pick some of your favorite images and put them under `./data/normal_visualization/image`

class VisualizationDataset(data.Dataset):
    def __init__(self, image_dir="./data/normal_visualization/image", image_ext=".png"):
        self.img_dir = image_dir
        self.img_ext = image_ext
        
        self.image_filenames = [
            os.path.splitext(os.path.basename(l))[0] for l in glob.glob(self.img_dir + "/*" + image_ext)
        ]

    def __len__(self):
        return len(self.image_filenames)

    def __getitem__(self, index):
        filename = self.image_filenames[index]
        img = Image.open(os.path.join(self.img_dir, filename) + self.img_ext)
        img = np.asarray(img).copy()
        img = ToTensor()(img)
        img = Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])(img)
        
        return img.contiguous(), filename

def simple_vis(model):
    model.eval()
    dataset = VisualizationDataset(image_dir="./data/normal_visualization/images")
    dataloader = data.DataLoader(dataset, batch_size=1, shuffle=False, 
                                 num_workers=2, drop_last=False)
    imgs, preds = [], []

    mean = np.array([0.485, 0.456, 0.406])
    std = np.array([0.229, 0.224, 0.225])

    with torch.no_grad():
        for i, batch in enumerate(tqdm(dataloader)):
            img, _ = batch
            img = img.to(device)

            pred = model(img)
            imgs.append(
                std * img[0].permute((1, 2, 0)).cpu().numpy() + mean
            )
            preds.append((pred[0].permute((1, 2, 0)).cpu().numpy() + 1) / 2)

    return imgs, preds

imgs, preds = simple_vis(model)
fig, axs = plt.subplots(ncols=5, nrows=2, figsize=(22, 7))
for idx, ax_i in enumerate(axs.T):
    ax = ax_i[0]
    ax.imshow(imgs[idx])
    ax.axis('off')
    ax = ax_i[1]
    ax.imshow(preds[idx])
    ax.axis('off')
fig.tight_layout()
plt.savefig('q2_visualization.pdf', format='pdf', bbox_inches='tight')

# Test your model on the test set, submit the output to gradescope

from PIL import Image

def simple_test(model, out_dir):
    model.eval()
    dataset = VisualizationDataset(image_dir="./data/Q2_test_data")
    dataloader = data.DataLoader(dataset, batch_size=1, shuffle=False, 
                                 num_workers=2, drop_last=False)

    with torch.no_grad():
        for i, batch in enumerate(tqdm(dataloader)):
            img, filename = batch
            img = img.to(device)

            pred = model(img)
            pred = ((pred[0].permute((1, 2, 0)).cpu().numpy() + 1) / 2) * 255
            pred = pred.astype(np.uint8)

            output = os.path.join(out_dir, filename[0] + ".png")

            Image.fromarray(pred).save(output)

out_dir = "Q2_normal_predictions"
os.makedirs(out_dir, exist_ok=True)
simple_test(model, out_dir)
