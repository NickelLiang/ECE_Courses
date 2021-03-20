## Multi-resolution Blending

1. **Method Description.** 
   <!-- *TODO*: Describe the key implementation details for blending. -->
    For this problem, I first convert all three images to grayscale. Then I compute the laplacian stack of two input image, by computing image with different gaussian filter and find their difference. Then I computed a gaussian stack, by computing the mask with different gaussian filter. Then I combine these three stacks with the equation given in the paper. Lastly, I stack these images together by simply adding them together and normalize the result.

2. **Oraple.** 
   <!-- *TODO:* Include visualizations of the Oraple blending along any variations your tried (include both original images and the blended image) -->

    <div align="center">
      <img src="apple.jpeg" width="40%">
      <img src="orange.jpeg" width="40%">
    </div>
    <div align="center">
      <img src="mask.png" width="40%">
      <img src="result.png" width="40%">
    </div>

3. **Blends of your choice.** 
   <!-- *TODO:* Include visualizations of blends of your choice (include both original images and the blended image). Describe any modifications you made on top of what worked for the oraple. -->
   <div align="center">
      <img src="l.png" width="40%">
      <img src="r.png" width="40%">
    </div>
    <div align="center">
      <img src="m2.png" width="40%">
      <img src="eye2.png" width="40%">
    </div>
    I attempted the famous eye on hand image blend. On top of the original oraple blend, I changed the depth of the image stack from 10 to 20 to get a visually pleasing result.