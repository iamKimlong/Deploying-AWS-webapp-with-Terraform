document.addEventListener('DOMContentLoaded', function() {
    console.log('Cloud Computing Project - Web Application Loaded');
    
    // Add status indicator
    addStatusIndicator();
    
    // Add refresh time
    addRefreshTime();
    
    // Add instance rotation display
    addInstanceRotation();
    
    // Monitor page performance
    monitorPerformance();
});

function addStatusIndicator() {
    const instanceInfo = document.querySelector('.instance-info h2');
    if (instanceInfo) {
        const status = document.createElement('span');
        status.className = 'status healthy';
        status.title = 'Instance is healthy';
        instanceInfo.prepend(status);
    }
}

function addRefreshTime() {
    const footer = document.querySelector('footer p');
    if (footer) {
        const time = new Date().toLocaleString();
        footer.innerHTML += ` | Page loaded at: ${time}`;
    }
}

function addInstanceRotation() {
    // Create a visual indicator for instance changes
    const container = document.querySelector('.instance-info');
    if (container) {
        const refreshBtn = document.createElement('button');
        refreshBtn.textContent = 'Refresh to See Load Balancing';
        refreshBtn.style.cssText = `
            margin-top: 1rem;
            padding: 0.5rem 1rem;
            background: #ff9900;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 1rem;
            transition: background 0.3s ease;
        `;
        refreshBtn.onmouseover = () => refreshBtn.style.background = '#e88600';
        refreshBtn.onmouseout = () => refreshBtn.style.background = '#ff9900';
        refreshBtn.onclick = () => location.reload();
        container.appendChild(refreshBtn);
    }
}

function monitorPerformance() {
    // Basic performance monitoring
    if (window.performance && window.performance.timing) {
        window.addEventListener('load', function() {
            setTimeout(function() {
                const timing = window.performance.timing;
                const loadTime = timing.loadEventEnd - timing.navigationStart;
                console.log('Page Load Time:', loadTime + 'ms');
                
                // Display load time
                const perfDiv = document.createElement('div');
                perfDiv.style.cssText = `
                    position: fixed;
                    bottom: 10px;
                    right: 10px;
                    background: rgba(35, 47, 62, 0.9);
                    color: white;
                    padding: 0.5rem 1rem;
                    border-radius: 4px;
                    font-size: 0.9rem;
                    font-family: monospace;
                `;
                perfDiv.textContent = `Load time: ${loadTime}ms`;
                document.body.appendChild(perfDiv);
                
                // Auto-hide after 5 seconds
                setTimeout(() => {
                    perfDiv.style.transition = 'opacity 0.5s ease';
                    perfDiv.style.opacity = '0';
                    setTimeout(() => perfDiv.remove(), 500);
                }, 5000);
            }, 0);
        });
    }
}

// Simulate real-time metrics update
setInterval(function() {
    const instanceId = document.getElementById('instance-id');
    if (instanceId && instanceId.textContent) {
        // Add a subtle animation to show the page is live
        instanceId.style.transition = 'opacity 0.5s ease';
        instanceId.style.opacity = '0.5';
        setTimeout(() => {
            instanceId.style.opacity = '1';
        }, 500);
    }
}, 30000); // Every 30 seconds

// Add keyboard shortcuts
document.addEventListener('keydown', function(e) {
    // Press 'R' to refresh
    if (e.key === 'r' && !e.ctrlKey && !e.metaKey) {
        location.reload();
    }
    // Press 'H' to highlight instance info
    if (e.key === 'h' && !e.ctrlKey && !e.metaKey) {
        const instanceSection = document.querySelector('.instance-info');
        if (instanceSection) {
            instanceSection.style.transition = 'all 0.3s ease';
            instanceSection.style.transform = 'scale(1.02)';
            instanceSection.style.boxShadow = '0 4px 30px rgba(255, 153, 0, 0.3)';
            setTimeout(() => {
                instanceSection.style.transform = 'scale(1)';
                instanceSection.style.boxShadow = '';
            }, 1000);
        }
    }
});

// Add connection status
function checkConnection() {
    const statusDiv = document.createElement('div');
    statusDiv.id = 'connection-status';
    statusDiv.style.cssText = `
        position: fixed;
        top: 10px;
        right: 10px;
        padding: 0.5rem 1rem;
        border-radius: 4px;
        font-size: 0.9rem;
        display: none;
    `;
    document.body.appendChild(statusDiv);
    
    window.addEventListener('online', function() {
        statusDiv.style.display = 'block';
        statusDiv.style.background = '#28a745';
        statusDiv.style.color = 'white';
        statusDiv.textContent = '✓ Connected';
        setTimeout(() => statusDiv.style.display = 'none', 3000);
    });
    
    window.addEventListener('offline', function() {
        statusDiv.style.display = 'block';
        statusDiv.style.background = '#dc3545';
        statusDiv.style.color = 'white';
        statusDiv.textContent = '✗ Connection Lost';
    });
}

checkConnection();
