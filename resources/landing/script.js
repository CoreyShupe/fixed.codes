for (let i = 0; i < 2_100; i++) {
    let star = document.createElement('div');
    star.className = 'star';
    star.style.top = Math.random() * 100 + '%';
    star.style.left = Math.random() * 100 + '%';
    star.style.width = Math.random() * 2 + 1 + 'px';
    star.style.height = Math.random() * 2 + 1 + 'px';
    document.body.appendChild(star);
}