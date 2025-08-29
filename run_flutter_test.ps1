# Flutter 앱 테스트 실행기 (PowerShell 버전)
param(
    [string]$Choice = ""
)

# UTF-8 인코딩 설정
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   우리들의아지트 Flutter 앱 실행기" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Flutter 환경 확인
Write-Host "Flutter 환경을 확인 중..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Flutter 환경 확인 완료!" -ForegroundColor Green
    } else {
        throw "Flutter not found"
    }
} catch {
    Write-Host "[오류] Flutter가 설치되어 있지 않거나 PATH에 등록되지 않았습니다." -ForegroundColor Red
    Write-Host "Flutter SDK를 설치하고 환경변수 PATH에 추가해주세요." -ForegroundColor Red
    Write-Host ""
    Read-Host "계속하려면 아무 키나 누르세요"
    exit 1
}

Write-Host ""

function Show-Menu {
    Write-Host "실행할 환경을 선택하세요:" -ForegroundColor White
    Write-Host ""
    Write-Host "1. Chrome 웹 브라우저 (포트 4693)" -ForegroundColor White
    Write-Host "2. Chrome 웹 브라우저 (기본 포트)" -ForegroundColor White
    Write-Host "3. Edge 웹 브라우저" -ForegroundColor White
    Write-Host "4. Windows 데스크톱 앱" -ForegroundColor White
    Write-Host "5. Flutter Doctor (환경 진단)" -ForegroundColor White
    Write-Host "6. Flutter Clean (빌드 캐시 정리)" -ForegroundColor White
    Write-Host "7. Flutter Pub Get (의존성 설치)" -ForegroundColor White
    Write-Host "8. 종료" -ForegroundColor White
    Write-Host ""
}

function Run-ChromePort {
    Write-Host ""
    Write-Host "Chrome에서 포트 4693으로 실행 중..." -ForegroundColor Green
    Write-Host "URL: http://localhost:4693" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[주의] Chrome이 설치되어 있어야 합니다." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        flutter run -d chrome --web-port 4693
    } catch {
        Write-Host ""
        Write-Host "[오류] Chrome에서 실행에 실패했습니다." -ForegroundColor Red
        Write-Host "Chrome이 설치되어 있는지 확인해주세요." -ForegroundColor Red
        Read-Host "계속하려면 아무 키나 누르세요"
    }
}

function Run-ChromeDefault {
    Write-Host ""
    Write-Host "Chrome에서 기본 포트로 실행 중..." -ForegroundColor Green
    Write-Host ""
    Write-Host "[주의] Chrome이 설치되어 있어야 합니다." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        flutter run -d chrome
    } catch {
        Write-Host ""
        Write-Host "[오류] Chrome에서 실행에 실패했습니다." -ForegroundColor Red
        Write-Host "Chrome이 설치되어 있는지 확인해주세요." -ForegroundColor Red
        Read-Host "계속하려면 아무 키나 누르세요"
    }
}

function Run-Edge {
    Write-Host ""
    Write-Host "Edge에서 실행 중..." -ForegroundColor Green
    Write-Host ""
    Write-Host "[주의] Microsoft Edge가 설치되어 있어야 합니다." -ForegroundColor Yellow
    Write-Host ""
    
    try {
        flutter run -d edge
    } catch {
        Write-Host ""
        Write-Host "[오류] Edge에서 실행에 실패했습니다." -ForegroundColor Red
        Write-Host "Microsoft Edge가 설치되어 있는지 확인해주세요." -ForegroundColor Red
        Read-Host "계속하려면 아무 키나 누르세요"
    }
}

function Run-Windows {
    Write-Host ""
    Write-Host "Windows 데스크톱 앱으로 실행 중..." -ForegroundColor Green
    Write-Host ""
    Write-Host "[주의] Windows 데스크톱 앱 실행을 위해서는 Visual Studio가 필요합니다." -ForegroundColor Yellow
    Write-Host "Visual Studio가 설치되어 있지 않으면 오류가 발생할 수 있습니다." -ForegroundColor Yellow
    Write-Host ""
    
    $continue = Read-Host "계속 진행하시겠습니까? (y/n)"
    if ($continue -eq "y" -or $continue -eq "Y") {
        try {
            flutter run -d windows
        } catch {
            Write-Host ""
            Write-Host "[오류] Windows 데스크톱 앱 실행에 실패했습니다." -ForegroundColor Red
            Write-Host "Visual Studio가 설치되어 있는지 확인해주세요." -ForegroundColor Red
            Read-Host "계속하려면 아무 키나 누르세요"
        }
    } else {
        Write-Host "Windows 데스크톱 앱 실행을 취소했습니다." -ForegroundColor Yellow
    }
    Write-Host ""
    Read-Host "계속하려면 아무 키나 누르세요"
}

function Run-Doctor {
    Write-Host ""
    Write-Host "Flutter 환경을 진단 중..." -ForegroundColor Green
    Write-Host ""
    
    try {
        flutter doctor -v
    } catch {
        Write-Host "[오류] Flutter doctor 실행에 실패했습니다." -ForegroundColor Red
    }
    
    Write-Host ""
    Read-Host "계속하려면 아무 키나 누르세요"
}

function Run-Clean {
    Write-Host ""
    Write-Host "빌드 캐시를 정리 중..." -ForegroundColor Green
    Write-Host ""
    
    try {
        flutter clean
    } catch {
        Write-Host ""
        Write-Host "[오류] Flutter clean 실행에 실패했습니다." -ForegroundColor Red
        Read-Host "계속하려면 아무 키나 누르세요"
    }
    
    Write-Host ""
    Read-Host "계속하려면 아무 키나 누르세요"
}

function Run-PubGet {
    Write-Host ""
    Write-Host "의존성 패키지를 설치 중..." -ForegroundColor Green
    Write-Host ""
    
    try {
        flutter pub get
    } catch {
        Write-Host ""
        Write-Host "[오류] Flutter pub get 실행에 실패했습니다." -ForegroundColor Red
        Read-Host "계속하려면 아무 키나 누르세요"
    }
    
    Write-Host ""
    Read-Host "계속하려면 아무 키나 누르세요"
}

# 메인 루프
do {
    Show-Menu
    
    if ($Choice -eq "") {
        $Choice = Read-Host "선택 (1-8)"
    }
    
    switch ($Choice) {
        "1" { Run-ChromePort; $Choice = "" }
        "2" { Run-ChromeDefault; $Choice = "" }
        "3" { Run-Edge; $Choice = "" }
        "4" { Run-Windows; $Choice = "" }
        "5" { Run-Doctor; $Choice = "" }
        "6" { Run-Clean; $Choice = "" }
        "7" { Run-PubGet; $Choice = "" }
        "8" { 
            Write-Host ""
            Write-Host "프로그램을 종료합니다." -ForegroundColor Yellow
            Write-Host ""
            Read-Host "계속하려면 아무 키나 누르세요"
            exit 0 
        }
        default { 
            Write-Host ""
            Write-Host "잘못된 선택입니다. 1-8 사이의 숫자를 입력하세요." -ForegroundColor Red
            Write-Host ""
            Read-Host "계속하려면 아무 키나 누르세요"
            $Choice = ""
        }
    }
} while ($true)
