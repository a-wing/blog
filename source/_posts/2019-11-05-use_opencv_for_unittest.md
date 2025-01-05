---
layout: post
title:  "使用 OpenCV 来做单元测试"
author: metal A-wing
date:   2019-11-05 17:00:00 +0800
comments: true
categories: program
---

最近一直都在搞图像传输，webrtc 可以检测网络状况来调整码率。为了探究图像传输中损失了多少数据，用 opencv 来计算输入视频流和输出视频流的相似性

不过本人作为一个不懂算法，不懂C++， 不懂openCV 的菜鸡。（我还真把这个东西给做出来了

### 如何检测视频视频的相似性
先来科普两个概念：
1. 峰值信噪比 PSNR (Peak signal-to-noise ratio)
https://en.wikipedia.org/wiki/Peak_signal-to-noise_ratio

2. 结构相似性 SSIM (Structural similarity)
https://en.wikipedia.org/wiki/Structural_similarity

这个处理本身是把视频拆成图像帧，然回分成 RGB 分辨对比

然回把这个代码直接拿过来用就行（好敷衍。。。

代码来源：https://docs.opencv.org/master/d5/dc4/tutorial_video_input_psnr_ssim.html
```cpp
#include <iostream> // for standard I/O
#include <string>   // for strings
#include <iomanip>  // for controlling float print precision
#include <sstream>  // string to number conversion
#include <opencv2/core.hpp>     // Basic OpenCV structures (cv::Mat, Scalar)
#include <opencv2/imgproc.hpp>  // Gaussian Blur
#include <opencv2/videoio.hpp>
#include <opencv2/highgui.hpp>  // OpenCV window I/O
using namespace std;
using namespace cv;
double getPSNR ( const Mat& I1, const Mat& I2);
Scalar getMSSIM( const Mat& I1, const Mat& I2);
static void help()
{
    cout
        << "------------------------------------------------------------------------------" << endl
        << "This program shows how to read a video file with OpenCV. In addition, it "
        << "tests the similarity of two input videos first with PSNR, and for the frames "
        << "below a PSNR trigger value, also with MSSIM."                                   << endl
        << "Usage:"                                                                         << endl
        << "./video-input-psnr-ssim <referenceVideo> <useCaseTestVideo> <PSNR_Trigger_Value> <Wait_Between_Frames> " << endl
        << "--------------------------------------------------------------------------"     << endl
        << endl;
}
int main(int argc, char *argv[])
{
    help();
    if (argc != 5)
    {
        cout << "Not enough parameters" << endl;
        return -1;
    }
    stringstream conv;
    const string sourceReference = argv[1], sourceCompareWith = argv[2];
    int psnrTriggerValue, delay;
    conv << argv[3] << endl << argv[4];       // put in the strings
    conv >> psnrTriggerValue >> delay;        // take out the numbers
    int frameNum = -1;          // Frame counter
    VideoCapture captRefrnc(sourceReference), captUndTst(sourceCompareWith);
    if (!captRefrnc.isOpened())
    {
        cout  << "Could not open reference " << sourceReference << endl;
        return -1;
    }
    if (!captUndTst.isOpened())
    {
        cout  << "Could not open case test " << sourceCompareWith << endl;
        return -1;
    }
    Size refS = Size((int) captRefrnc.get(CAP_PROP_FRAME_WIDTH),
                     (int) captRefrnc.get(CAP_PROP_FRAME_HEIGHT)),
         uTSi = Size((int) captUndTst.get(CAP_PROP_FRAME_WIDTH),
                     (int) captUndTst.get(CAP_PROP_FRAME_HEIGHT));
    if (refS != uTSi)
    {
        cout << "Inputs have different size!!! Closing." << endl;
        return -1;
    }
    const char* WIN_UT = "Under Test";
    const char* WIN_RF = "Reference";
    // Windows
    namedWindow(WIN_RF, WINDOW_AUTOSIZE);
    namedWindow(WIN_UT, WINDOW_AUTOSIZE);
    moveWindow(WIN_RF, 400       , 0);         //750,  2 (bernat =0)
    moveWindow(WIN_UT, refS.width, 0);         //1500, 2
    cout << "Reference frame resolution: Width=" << refS.width << "  Height=" << refS.height
         << " of nr#: " << captRefrnc.get(CAP_PROP_FRAME_COUNT) << endl;
    cout << "PSNR trigger value " << setiosflags(ios::fixed) << setprecision(3)
         << psnrTriggerValue << endl;
    Mat frameReference, frameUnderTest;
    double psnrV;
    Scalar mssimV;
    for(;;) //Show the image captured in the window and repeat
    {
        captRefrnc >> frameReference;
        captUndTst >> frameUnderTest;
        if (frameReference.empty() || frameUnderTest.empty())
        {
            cout << " < < <  Game over!  > > > ";
            break;
        }
        ++frameNum;
        cout << "Frame: " << frameNum << "# ";
        psnrV = getPSNR(frameReference,frameUnderTest);
        cout << setiosflags(ios::fixed) << setprecision(3) << psnrV << "dB";
        if (psnrV < psnrTriggerValue && psnrV)
        {
            mssimV = getMSSIM(frameReference, frameUnderTest);
            cout << " MSSIM: "
                << " R " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[2] * 100 << "%"
                << " G " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[1] * 100 << "%"
                << " B " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[0] * 100 << "%";
        }
        cout << endl;
        imshow(WIN_RF, frameReference);
        imshow(WIN_UT, frameUnderTest);
        char c = (char)waitKey(delay);
        if (c == 27) break;
    }
    return 0;
}
double getPSNR(const Mat& I1, const Mat& I2)
{
    Mat s1;
    absdiff(I1, I2, s1);       // |I1 - I2|
    s1.convertTo(s1, CV_32F);  // cannot make a square on 8 bits
    s1 = s1.mul(s1);           // |I1 - I2|^2
    Scalar s = sum(s1);        // sum elements per channel
    double sse = s.val[0] + s.val[1] + s.val[2]; // sum channels
    if( sse <= 1e-10) // for small values return zero
        return 0;
    else
    {
        double mse  = sse / (double)(I1.channels() * I1.total());
        double psnr = 10.0 * log10((255 * 255) / mse);
        return psnr;
    }
}
Scalar getMSSIM( const Mat& i1, const Mat& i2)
{
    const double C1 = 6.5025, C2 = 58.5225;
    /***************************** INITS **********************************/
    int d = CV_32F;
    Mat I1, I2;
    i1.convertTo(I1, d);            // cannot calculate on one byte large values
    i2.convertTo(I2, d);
    Mat I2_2   = I2.mul(I2);        // I2^2
    Mat I1_2   = I1.mul(I1);        // I1^2
    Mat I1_I2  = I1.mul(I2);        // I1 * I2
    /*************************** END INITS **********************************/
    Mat mu1, mu2;                   // PRELIMINARY COMPUTING
    GaussianBlur(I1, mu1, Size(11, 11), 1.5);
    GaussianBlur(I2, mu2, Size(11, 11), 1.5);
    Mat mu1_2   =   mu1.mul(mu1);
    Mat mu2_2   =   mu2.mul(mu2);
    Mat mu1_mu2 =   mu1.mul(mu2);
    Mat sigma1_2, sigma2_2, sigma12;
    GaussianBlur(I1_2, sigma1_2, Size(11, 11), 1.5);
    sigma1_2 -= mu1_2;
    GaussianBlur(I2_2, sigma2_2, Size(11, 11), 1.5);
    sigma2_2 -= mu2_2;
    GaussianBlur(I1_I2, sigma12, Size(11, 11), 1.5);
    sigma12 -= mu1_mu2;
    Mat t1, t2, t3;
    t1 = 2 * mu1_mu2 + C1;
    t2 = 2 * sigma12 + C2;
    t3 = t1.mul(t2);                 // t3 = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))
    t1 = mu1_2 + mu2_2 + C1;
    t2 = sigma1_2 + sigma2_2 + C2;
    t1 = t1.mul(t2);                 // t1 =((mu1_2 + mu2_2 + C1).*(sigma1_2 + sigma2_2 + C2))
    Mat ssim_map;
    divide(t3, t1, ssim_map);        // ssim_map =  t3./t1;
    Scalar mssim = mean(ssim_map);   // mssim = average of ssim map
    return mssim;
}
```

嗯？ 不想看英文。这里有个中文版（不过不建议看这个中文版）https://www.w3cschool.cn/opencv/opencv-v4na2dr6.html

之后编译源码
```sh
# 安装依赖 我在 debian:buster 上测试运行的
apt-get update -y && apt-get install -y libopencv-dev g++ wget

g++ video-input-psnr-ssim.cpp -o video-input-psnr-ssim -I /usr/include/opencv4 -L /usr/lib -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_videoio
```

这样来运行：
```sh
wget https://github.com/opencv/opencv/raw/master/samples/data/Megamind.avi
wget https://github.com/opencv/opencv/raw/master/samples/data/Megamind_bugy.avi
./video-input-psnr-ssim Megamind.avi Megamind_bugy.avi 35 10
```

### 之后就是把这个流程自动化

这个要跑在 ci 里自动输出结果的。显示窗口可不行，还要改造一下。直接去掉窗口。很容易，C++ 的基础

把结果算平均值已经有人写好了 https://github.com/yeokm1/ssim

直接把那段代码拿过来就能用

我们用 gstreamer videotestsrc 来做视频源

```sh
gst-launch-1.0 videotestsrc ! videoconvert ! autovideosink
```

然回用 webrtc 去发送这段视频

可以用这个项目来发送视频 https://github.com/pion/webrtc/tree/master/examples/play-from-disk

当然是可以使用 cgo 的。用go 去调用 gstreamer 。这样可以少一步图像转换
https://github.com/pion/example-webrtc-applications/tree/master/gstreamer-send

然回另一端接收图像。保存成文件
https://github.com/pion/webrtc/tree/master/examples/save-to-disk

之后把这个坨都放在 gitlab ci 里

我最终输出的结果长这样：
```
< < < === END === > > >
Final Results
R 96.10% G 95.99% B 92.14%
Similarity = 94.74%
```

然回在 `Setting` > `CI / CD` > `General pipelines` > `Test coverage parsing` 里这样写：
```
Similarity = \d+.\d+%
```

这样就把视频相识度结果输出到代码覆盖率上了（对于这种图像传输算相似度才有意义 （（（大雾

