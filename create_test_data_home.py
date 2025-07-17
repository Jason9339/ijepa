#!/usr/bin/env python3
"""
創建測試用的模擬ImageNet資料（家目錄版本）
"""

import os
import numpy as np
from PIL import Image

def create_test_imagenet_data(root_path=None, num_classes=5, images_per_class=10):
    """
    創建模擬的ImageNet格式資料
    """
    if root_path is None:
        # 使用家目錄路徑
        home_dir = os.environ.get('HOME', '/dicos_ui_home/zihcilin39')
        root_path = f"{home_dir}/ijepa_test_data"
    
    data_path = os.path.join(root_path, "imagenet_full_size/061417/train")
    os.makedirs(data_path, exist_ok=True)
    
    print(f"在 {data_path} 創建測試資料...")
    
    # 創建幾個類別的模擬資料
    class_names = [f"n{i:08d}" for i in range(num_classes)]
    
    for class_name in class_names:
        class_dir = os.path.join(data_path, class_name)
        os.makedirs(class_dir, exist_ok=True)
        
        # 為每個類別創建一些隨機圖像
        for i in range(images_per_class):
            # 創建隨機的RGB圖像 (224x224)
            random_image = np.random.randint(0, 256, (224, 224, 3), dtype=np.uint8)
            img = Image.fromarray(random_image)
            
            # 儲存圖像
            img_path = os.path.join(class_dir, f"{class_name}_{i:04d}.JPEG")
            img.save(img_path, "JPEG")
        
        print(f"為類別 {class_name} 創建了 {images_per_class} 張圖像")
    
    print(f"測試資料創建完成！總共 {num_classes} 個類別，每個類別 {images_per_class} 張圖像")
    print(f"資料路徑: {data_path}")

if __name__ == "__main__":
    create_test_imagenet_data() 